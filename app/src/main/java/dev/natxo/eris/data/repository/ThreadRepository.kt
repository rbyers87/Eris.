package dev.natxo.eris.data.repository

import kotlinx.coroutines.flow.Flow
import dev.natxo.eris.data.database.dao.ThreadDao
import dev.natxo.eris.data.database.entities.Thread
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ThreadRepository @Inject constructor(
    private val threadDao: ThreadDao
) {
    fun getAllThreads(): Flow<List<Thread>> = threadDao.getAllThreads()

    suspend fun getThreadById(id: String): Thread? = threadDao.getThreadById(id)

    suspend fun insertThread(thread: Thread) = threadDao.insertThread(thread)

    suspend fun updateThread(thread: Thread) = threadDao.updateThread(thread)

    suspend fun deleteThread(thread: Thread) = threadDao.deleteThread(thread)

    suspend fun deleteAllThreads() = threadDao.deleteAllThreads()
}