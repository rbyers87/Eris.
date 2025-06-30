package dev.natxo.eris.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.preferences.PreferencesManager
import dev.natxo.eris.data.repository.ModelRepository
import dev.natxo.eris.ml.ModelManager
import javax.inject.Inject

enum class OnboardingStep {
    WELCOME, MODEL_SELECTION, DOWNLOAD
}

data class OnboardingUiState(
    val currentStep: OnboardingStep = OnboardingStep.WELCOME,
    val availableModels: List<AIModel> = emptyList(),
    val selectedModel: AIModel? = null,
    val downloadProgress: Float = 0f,
    val isDownloading: Boolean = false,
    val downloadError: String? = null,
    val isOnboardingComplete: Boolean = false
)

@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val modelRepository: ModelRepository,
    private val modelManager: ModelManager,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(OnboardingUiState())
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    init {
        loadAvailableModels()
    }

    private fun loadAvailableModels() {
        _uiState.value = _uiState.value.copy(
            availableModels = modelRepository.availableModels
        )
    }

    fun nextStep() {
        val currentStep = _uiState.value.currentStep
        val nextStep = when (currentStep) {
            OnboardingStep.WELCOME -> OnboardingStep.MODEL_SELECTION
            OnboardingStep.MODEL_SELECTION -> OnboardingStep.DOWNLOAD
            OnboardingStep.DOWNLOAD -> return // Already at final step
        }
        
        _uiState.value = _uiState.value.copy(currentStep = nextStep)
    }

    fun selectModel(model: AIModel) {
        _uiState.value = _uiState.value.copy(selectedModel = model)
    }

    fun startDownload() {
        val selectedModel = _uiState.value.selectedModel ?: return
        
        _uiState.value = _uiState.value.copy(
            isDownloading = true,
            downloadProgress = 0f,
            downloadError = null
        )

        viewModelScope.launch {
            modelManager.downloadModel(selectedModel) { progress ->
                _uiState.value = _uiState.value.copy(downloadProgress = progress)
            }.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(
                        isDownloading = false,
                        downloadProgress = 1f
                    )
                    preferencesManager.setActiveModel(selectedModel.id)
                },
                onFailure = { error ->
                    _uiState.value = _uiState.value.copy(
                        isDownloading = false,
                        downloadError = error.message ?: "Download failed"
                    )
                }
            )
        }
    }

    fun retryDownload() {
        _uiState.value = _uiState.value.copy(
            downloadError = null,
            downloadProgress = 0f
        )
        startDownload()
    }

    fun completeOnboarding() {
        viewModelScope.launch {
            preferencesManager.setOnboardingCompleted(true)
            _uiState.value = _uiState.value.copy(isOnboardingComplete = true)
        }
    }
}