package dev.natxo.eris.data.database

import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import android.content.Context
import dev.natxo.eris.data.database.dao.MessageDao
import dev.natxo.eris.data.database.dao.ThreadDao
import dev.natxo.eris.data.database.entities.Message
import dev.natxo.eris.data.database.entities.Thread

@Database(
    entities = [Thread::class, Message::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class ErisDatabase : RoomDatabase() {
    abstract fun threadDao(): ThreadDao
    abstract fun messageDao(): MessageDao

    companion object {
        const val DATABASE_NAME = "eris_database"
    }
}