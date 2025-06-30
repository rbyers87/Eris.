package dev.natxo.eris.ml

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import okhttp3.*
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.repository.ModelRepository

@Singleton
class ModelManager @Inject constructor(
    private val context: Context,
    private val modelRepository: ModelRepository,
    private val httpClient: OkHttpClient
) {
    private val _isGenerating = MutableStateFlow(false)
    val isGenerating: Flow<Boolean> = _isGenerating.asStateFlow()

    private val _generatedText = MutableStateFlow("")
    val generatedText: Flow<String> = _generatedText.asStateFlow()

    private val modelsDir = File(context.filesDir, "models")

    init {
        if (!modelsDir.exists()) {
            modelsDir.mkdirs()
        }
    }

    suspend fun downloadModel(
        model: AIModel,
        onProgress: (Float) -> Unit
    ): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            modelRepository.startDownload(model.id)
            
            val modelDir = File(modelsDir, model.id)
            if (!modelDir.exists()) {
                modelDir.mkdirs()
            }

            // Download model files (simplified - in real implementation you'd download actual model files)
            val configFile = File(modelDir, "config.json")
            val tokenizerFile = File(modelDir, "tokenizer.json")
            val modelFile = File(modelDir, "model.onnx")

            // Simulate download progress
            for (i in 0..100 step 10) {
                onProgress(i / 100f)
                modelRepository.updateDownloadProgress(model.id, i / 100f)
                kotlinx.coroutines.delay(100) // Simulate download time
            }

            // Create placeholder files (in real implementation, download actual files)
            configFile.writeText("""{"model_type": "${model.id}"}""")
            tokenizerFile.writeText("""{"vocab_size": 32000}""")
            modelFile.writeText("placeholder model data")

            modelRepository.markModelAsDownloaded(model.id)
            modelRepository.finishDownload(model.id)
            
            Result.success(Unit)
        } catch (e: Exception) {
            modelRepository.finishDownload(model.id)
            Result.failure(e)
        }
    }

    suspend fun generateResponse(
        model: AIModel,
        messages: List<dev.natxo.eris.data.database.entities.Message>,
        onTokenGenerated: (String) -> Unit
    ): Result<String> = withContext(Dispatchers.IO) {
        try {
            _isGenerating.value = true
            _generatedText.value = ""

            // Simulate AI response generation
            val responses = listOf(
                "I'm Eris, your private AI assistant running locally on your Android device. ",
                "I can help you with various tasks while keeping all our conversations completely private. ",
                "What would you like to know or discuss today?"
            )

            var fullResponse = ""
            for (part in responses) {
                for (char in part) {
                    fullResponse += char
                    _generatedText.value = fullResponse
                    onTokenGenerated(fullResponse)
                    kotlinx.coroutines.delay(50) // Simulate typing speed
                }
            }

            _isGenerating.value = false
            Result.success(fullResponse)
        } catch (e: Exception) {
            _isGenerating.value = false
            Result.failure(e)
        }
    }

    suspend fun deleteModel(modelId: String) {
        val modelDir = File(modelsDir, modelId)
        if (modelDir.exists()) {
            modelDir.deleteRecursively()
        }
        modelRepository.removeDownloadedModel(modelId)
    }

    fun stopGeneration() {
        _isGenerating.value = false
    }
}