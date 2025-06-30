package dev.natxo.eris.data.database.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import dev.natxo.eris.data.database.entities.Thread

@Dao
interface ThreadDao {
    @Query("SELECT * FROM threads ORDER BY isPinned DESC, updatedAt DESC")
    fun getAllThreads(): Flow<List<Thread>>

    @Query("SELECT * FROM threads WHERE id = :id")
    suspend fun getThreadById(id: String): Thread?

    @Insert
    suspend fun insertThread(thread: Thread)

    @Update
    suspend fun updateThread(thread: Thread)

    @Delete
    suspend fun deleteThread(thread: Thread)

    @Query("DELETE FROM threads")
    suspend fun deleteAllThreads()
}