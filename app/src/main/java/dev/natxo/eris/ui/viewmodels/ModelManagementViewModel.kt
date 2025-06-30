package dev.natxo.eris.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.preferences.PreferencesManager
import dev.natxo.eris.data.repository.ModelRepository
import dev.natxo.eris.ml.ModelManager
import javax.inject.Inject

data class ModelManagementUiState(
    val availableModels: List<AIModel> = emptyList(),
    val downloadedModels: Set<String> = emptySet(),
    val downloadingModels: Set<String> = emptySet(),
    val downloadProgress: Map<String, Float> = emptyMap(),
    val activeModelId: String? = null
)

@HiltViewModel
class ModelManagementViewModel @Inject constructor(
    private val modelRepository: ModelRepository,
    private val modelManager: ModelManager,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(ModelManagementUiState())
    val uiState: StateFlow<ModelManagementUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            // Load available models
            _uiState.value = _uiState.value.copy(
                availableModels = modelRepository.availableModels
            )

            // Load downloaded models
            modelRepository.loadDownloadedModels()

            // Combine all flows
            combine(
                modelRepository.downloadedModels,
                modelRepository.downloadingModels,
                modelRepository.downloadProgress,
                preferencesManager.activeModel
            ) { downloaded, downloading, progress, activeModel ->
                _uiState.value = _uiState.value.copy(
                    downloadedModels = downloaded,
                    downloadingModels = downloading,
                    downloadProgress = progress,
                    activeModelId = activeModel
                )
            }.collect()
        }
    }

    fun downloadModel(model: AIModel) {
        viewModelScope.launch {
            modelManager.downloadModel(model) { progress ->
                // Progress is handled by ModelRepository flows
            }.fold(
                onSuccess = {
                    // Success is handled by ModelRepository flows
                },
                onFailure = { error ->
                    // Handle error (could show snackbar or dialog)
                    println("Download failed: ${error.message}")
                }
            )
        }
    }

    fun deleteModel(model: AIModel) {
        viewModelScope.launch {
            modelManager.deleteModel(model.id)
            
            // If this was the active model, clear it
            if (_uiState.value.activeModelId == model.id) {
                preferencesManager.setActiveModel("")
            }
        }
    }

    fun setActiveModel(model: AIModel) {
        viewModelScope.launch {
            preferencesManager.setActiveModel(model.id)
        }
    }
}