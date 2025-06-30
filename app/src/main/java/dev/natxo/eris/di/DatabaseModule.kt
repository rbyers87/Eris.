package dev.natxo.eris.di

import android.content.Context
import androidx.room.Room
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import dev.natxo.eris.data.database.ErisDatabase
import dev.natxo.eris.data.database.dao.MessageDao
import dev.natxo.eris.data.database.dao.ThreadDao
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideErisDatabase(@ApplicationContext context: Context): ErisDatabase {
        return Room.databaseBuilder(
            context,
            ErisDatabase::class.java,
            ErisDatabase.DATABASE_NAME
        ).build()
    }

    @Provides
    fun provideThreadDao(database: ErisDatabase): ThreadDao = database.threadDao()

    @Provides
    fun provideMessageDao(database: ErisDatabase): MessageDao = database.messageDao()
}