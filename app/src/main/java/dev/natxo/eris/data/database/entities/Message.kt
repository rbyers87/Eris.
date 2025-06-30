package dev.natxo.eris.data.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(
    tableName = "messages",
    foreignKeys = [
        ForeignKey(
            entity = Thread::class,
            parentColumns = ["id"],
            childColumns = ["threadId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class Message(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val threadId: String,
    val content: String,
    val role: MessageRole,
    val timestamp: Date = Date()
)

enum class MessageRole {
    USER, ASSISTANT, SYSTEM
}