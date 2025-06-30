package dev.natxo.eris.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import dev.natxo.eris.data.database.entities.Thread
import dev.natxo.eris.data.repository.ThreadRepository
import javax.inject.Inject

data class HomeUiState(
    val threads: List<Thread> = emptyList(),
    val isLoading: Boolean = false
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val threadRepository: ThreadRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadThreads()
    }

    private fun loadThreads() {
        viewModelScope.launch {
            threadRepository.getAllThreads().collect { threads ->
                _uiState.value = _uiState.value.copy(threads = threads)
            }
        }
    }

    fun createNewThread(onNavigateToChat: (String) -> Unit) {
        viewModelScope.launch {
            val newThread = Thread()
            threadRepository.insertThread(newThread)
            onNavigateToChat(newThread.id)
        }
    }

    fun deleteThread(thread: Thread) {
        viewModelScope.launch {
            threadRepository.deleteThread(thread)
        }
    }
}