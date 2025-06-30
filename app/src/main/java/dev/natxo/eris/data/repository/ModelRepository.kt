package dev.natxo.eris.data.repository

import android.content.Context
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.models.ModelCategory
import dev.natxo.eris.data.preferences.PreferencesManager
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ModelRepository @Inject constructor(
    private val context: Context,
    private val preferencesManager: PreferencesManager
) {
    private val _downloadedModels = MutableStateFlow<Set<String>>(emptySet())
    val downloadedModels: Flow<Set<String>> = _downloadedModels.asStateFlow()

    private val _downloadingModels = MutableStateFlow<Set<String>>(emptySet())
    val downloadingModels: Flow<Set<String>> = _downloadingModels.asStateFlow()

    private val _downloadProgress = MutableStateFlow<Map<String, Float>>(emptyMap())
    val downloadProgress: Flow<Map<String, Float>> = _downloadProgress.asStateFlow()

    // Available models registry
    val availableModels = listOf(
        AIModel(
            id = "llama3_2_1B",
            displayName = "Llama 3.2 1B",
            description = "Meta's efficient model, great for everyday conversations",
            category = ModelCategory.GENERAL,
            parameterCount = "1B",
            quantization = "4-bit",
            estimatedSize = 800L * 1024 * 1024, // 800MB
            minimumRAM = 2L * 1024 * 1024 * 1024, // 2GB
            downloadUrl = "https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-4bit",
            configUrl = "https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-4bit/resolve/main/config.json",
            tokenizerUrl = "https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-4bit/resolve/main/tokenizer.json"
        ),
        AIModel(
            id = "qwen2_5_0_5B",
            displayName = "Qwen 2.5 0.5B",
            description = "Ultra-lightweight multilingual model",
            category = ModelCategory.GENERAL,
            parameterCount = "0.5B",
            quantization = "4-bit",
            estimatedSize = 400L * 1024 * 1024, // 400MB
            minimumRAM = 1536L * 1024 * 1024, // 1.5GB
            downloadUrl = "https://huggingface.co/mlx-community/Qwen2.5-0.5B-Instruct-4bit",
            configUrl = "https://huggingface.co/mlx-community/Qwen2.5-0.5B-Instruct-4bit/resolve/main/config.json",
            tokenizerUrl = "https://huggingface.co/mlx-community/Qwen2.5-0.5B-Instruct-4bit/resolve/main/tokenizer.json"
        ),
        AIModel(
            id = "deepseekR1_1_5B",
            displayName = "DeepSeek R1 1.5B",
            description = "Advanced reasoning with efficient quantization",
            category = ModelCategory.REASONING,
            parameterCount = "1.5B",
            quantization = "4-bit",
            estimatedSize = 1200L * 1024 * 1024, // 1.2GB
            minimumRAM = 3L * 1024 * 1024 * 1024, // 3GB
            downloadUrl = "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit",
            configUrl = "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit/resolve/main/config.json",
            tokenizerUrl = "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit/resolve/main/tokenizer.json"
        )
    )

    fun getModelsByCategory(category: ModelCategory): List<AIModel> {
        return availableModels.filter { it.category == category }
    }

    fun getModelById(id: String): AIModel? {
        return availableModels.find { it.id == id }
    }

    suspend fun isModelDownloaded(modelId: String): Boolean {
        return _downloadedModels.value.contains(modelId)
    }

    suspend fun markModelAsDownloaded(modelId: String) {
        _downloadedModels.value = _downloadedModels.value + modelId
        preferencesManager.saveDownloadedModels(_downloadedModels.value)
    }

    suspend fun removeDownloadedModel(modelId: String) {
        _downloadedModels.value = _downloadedModels.value - modelId
        preferencesManager.saveDownloadedModels(_downloadedModels.value)
    }

    suspend fun loadDownloadedModels() {
        _downloadedModels.value = preferencesManager.getDownloadedModels()
    }

    fun updateDownloadProgress(modelId: String, progress: Float) {
        _downloadProgress.value = _downloadProgress.value + (modelId to progress)
    }

    fun startDownload(modelId: String) {
        _downloadingModels.value = _downloadingModels.value + modelId
    }

    fun finishDownload(modelId: String) {
        _downloadingModels.value = _downloadingModels.value - modelId
        _downloadProgress.value = _downloadProgress.value - modelId
    }
}