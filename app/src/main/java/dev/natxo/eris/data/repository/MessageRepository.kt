package dev.natxo.eris.data.repository

import kotlinx.coroutines.flow.Flow
import dev.natxo.eris.data.database.dao.MessageDao
import dev.natxo.eris.data.database.entities.Message
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MessageRepository @Inject constructor(
    private val messageDao: MessageDao
) {
    fun getMessagesForThread(threadId: String): Flow<List<Message>> = 
        messageDao.getMessagesForThread(threadId)

    suspend fun getLastMessageForThread(threadId: String): Message? = 
        messageDao.getLastMessageForThread(threadId)

    suspend fun insertMessage(message: Message) = messageDao.insertMessage(message)

    suspend fun updateMessage(message: Message) = messageDao.updateMessage(message)

    suspend fun deleteMessage(message: Message) = messageDao.deleteMessage(message)

    suspend fun deleteMessagesForThread(threadId: String) = 
        messageDao.deleteMessagesForThread(threadId)

    suspend fun deleteAllMessages() = messageDao.deleteAllMessages()
}