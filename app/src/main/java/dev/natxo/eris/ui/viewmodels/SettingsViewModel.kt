package dev.natxo.eris.ui.viewmodels

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import dev.natxo.eris.data.models.DeviceInfo
import dev.natxo.eris.data.preferences.PreferencesManager
import dev.natxo.eris.data.repository.MessageRepository
import dev.natxo.eris.data.repository.ModelRepository
import dev.natxo.eris.data.repository.ThreadRepository
import javax.inject.Inject

data class SettingsUiState(
    val activeModelName: String? = null,
    val hapticsEnabled: Boolean = true,
    val themeMode: String = "system",
    val deviceInfo: DeviceInfo = DeviceInfo("Unknown", "Unknown", 0, 0, false, emptyList()),
    val showDeleteAllDataDialog: Boolean = false
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    @ApplicationContext private val context: Context,
    private val preferencesManager: PreferencesManager,
    private val modelRepository: ModelRepository,
    private val threadRepository: ThreadRepository,
    private val messageRepository: MessageRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadSettings()
    }

    private fun loadSettings() {
        viewModelScope.launch {
            // Load device info
            val deviceInfo = DeviceInfo.fromContext(context)
            _uiState.value = _uiState.value.copy(deviceInfo = deviceInfo)

            // Combine all preference flows
            combine(
                preferencesManager.activeModel,
                preferencesManager.hapticsEnabled,
                preferencesManager.themeMode
            ) { activeModelId, hapticsEnabled, themeMode ->
                val activeModelName = activeModelId?.let { id ->
                    modelRepository.getModelById(id)?.displayName
                }

                _uiState.value = _uiState.value.copy(
                    activeModelName = activeModelName,
                    hapticsEnabled = hapticsEnabled,
                    themeMode = themeMode
                )
            }.collect()
        }
    }

    fun setHapticsEnabled(enabled: Boolean) {
        viewModelScope.launch {
            preferencesManager.setHapticsEnabled(enabled)
        }
    }

    fun setThemeMode(mode: String) {
        viewModelScope.launch {
            preferencesManager.setThemeMode(mode)
        }
    }

    fun showDeleteAllDataDialog() {
        _uiState.value = _uiState.value.copy(showDeleteAllDataDialog = true)
    }

    fun hideDeleteAllDataDialog() {
        _uiState.value = _uiState.value.copy(showDeleteAllDataDialog = false)
    }

    fun deleteAllData() {
        viewModelScope.launch {
            // Delete all messages and threads
            messageRepository.deleteAllMessages()
            threadRepository.deleteAllThreads()

            // Delete all downloaded models
            val downloadedModels = preferencesManager.getDownloadedModels()
            downloadedModels.forEach { modelId ->
                modelRepository.removeDownloadedModel(modelId)
            }

            // Reset preferences
            preferencesManager.setActiveModel("")
            preferencesManager.setOnboardingCompleted(false)
        }
    }
}