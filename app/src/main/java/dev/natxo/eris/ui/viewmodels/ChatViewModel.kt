package dev.natxo.eris.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import dev.natxo.eris.data.database.entities.Message
import dev.natxo.eris.data.database.entities.MessageRole
import dev.natxo.eris.data.database.entities.Thread
import dev.natxo.eris.data.preferences.PreferencesManager
import dev.natxo.eris.data.repository.MessageRepository
import dev.natxo.eris.data.repository.ModelRepository
import dev.natxo.eris.data.repository.ThreadRepository
import dev.natxo.eris.ml.ModelManager
import java.util.*
import javax.inject.Inject

data class ChatUiState(
    val thread: Thread? = null,
    val messages: List<Message> = emptyList(),
    val inputMessage: String = "",
    val isGenerating: Boolean = false,
    val generatedText: String = "",
    val error: String? = null
)

@HiltViewModel
class ChatViewModel @Inject constructor(
    private val threadRepository: ThreadRepository,
    private val messageRepository: MessageRepository,
    private val modelRepository: ModelRepository,
    private val modelManager: ModelManager,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    private var currentThreadId: String? = null

    init {
        // Observe generated text from ModelManager
        viewModelScope.launch {
            modelManager.generatedText.collect { text ->
                _uiState.value = _uiState.value.copy(generatedText = text)
            }
        }

        // Observe generation status
        viewModelScope.launch {
            modelManager.isGenerating.collect { isGenerating ->
                _uiState.value = _uiState.value.copy(isGenerating = isGenerating)
            }
        }
    }

    fun loadThread(threadId: String) {
        if (currentThreadId == threadId) return
        
        currentThreadId = threadId
        
        viewModelScope.launch {
            // Load thread
            val thread = threadRepository.getThreadById(threadId)
            _uiState.value = _uiState.value.copy(thread = thread)

            // Load messages
            messageRepository.getMessagesForThread(threadId).collect { messages ->
                _uiState.value = _uiState.value.copy(messages = messages)
            }
        }
    }

    fun updateInputMessage(message: String) {
        _uiState.value = _uiState.value.copy(inputMessage = message)
    }

    fun sendMessage() {
        val currentState = _uiState.value
        val threadId = currentState.thread?.id ?: return
        val messageText = currentState.inputMessage.trim()
        
        if (messageText.isEmpty() || currentState.isGenerating) return

        viewModelScope.launch {
            // Clear input
            _uiState.value = _uiState.value.copy(inputMessage = "")

            // Add user message
            val userMessage = Message(
                threadId = threadId,
                content = messageText,
                role = MessageRole.USER
            )
            messageRepository.insertMessage(userMessage)

            // Update thread title if it's the first message
            val thread = currentState.thread
            if (thread != null && thread.title == "New Chat") {
                val words = messageText.split(" ").take(5)
                val newTitle = words.joinToString(" ") + if (messageText.length > words.joinToString(" ").length) "..." else ""
                val updatedThread = thread.copy(title = newTitle, updatedAt = Date())
                threadRepository.updateThread(updatedThread)
            }

            // Generate AI response
            generateAIResponse(threadId)
        }
    }

    private suspend fun generateAIResponse(threadId: String) {
        val activeModelId = preferencesManager.activeModel.first() ?: return
        val model = modelRepository.getModelById(activeModelId) ?: return
        val messages = _uiState.value.messages

        modelManager.generateResponse(
            model = model,
            messages = messages,
            onTokenGenerated = { /* Already handled by flow */ }
        ).fold(
            onSuccess = { response ->
                // Add assistant message
                val assistantMessage = Message(
                    threadId = threadId,
                    content = response,
                    role = MessageRole.ASSISTANT
                )
                messageRepository.insertMessage(assistantMessage)

                // Update thread timestamp
                val thread = _uiState.value.thread
                if (thread != null) {
                    threadRepository.updateThread(thread.copy(updatedAt = Date()))
                }
            },
            onFailure = { error ->
                _uiState.value = _uiState.value.copy(
                    error = error.message ?: "Failed to generate response"
                )
            }
        )
    }

    fun stopGeneration() {
        modelManager.stopGeneration()
    }
}