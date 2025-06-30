package dev.natxo.eris.data.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(tableName = "threads")
data class Thread(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val title: String = "New Chat",
    val createdAt: Date = Date(),
    val updatedAt: Date = Date(),
    val isPinned: Boolean = false
)