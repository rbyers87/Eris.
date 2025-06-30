package dev.natxo.eris.data.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "eris_preferences")

@Singleton
class PreferencesManager @Inject constructor(
    private val context: Context
) {
    private object PreferencesKeys {
        val ACTIVE_MODEL = stringPreferencesKey("active_model")
        val DOWNLOADED_MODELS = stringSetPreferencesKey("downloaded_models")
        val HAPTICS_ENABLED = booleanPreferencesKey("haptics_enabled")
        val THEME_MODE = stringPreferencesKey("theme_mode")
        val HAS_COMPLETED_ONBOARDING = booleanPreferencesKey("has_completed_onboarding")
    }

    val activeModel: Flow<String?> = context.dataStore.data.map { preferences ->
        preferences[PreferencesKeys.ACTIVE_MODEL]
    }

    val downloadedModels: Flow<Set<String>> = context.dataStore.data.map { preferences ->
        preferences[PreferencesKeys.DOWNLOADED_MODELS] ?: emptySet()
    }

    val hapticsEnabled: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[PreferencesKeys.HAPTICS_ENABLED] ?: true
    }

    val themeMode: Flow<String> = context.dataStore.data.map { preferences ->
        preferences[PreferencesKeys.THEME_MODE] ?: "system"
    }

    val hasCompletedOnboarding: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[PreferencesKeys.HAS_COMPLETED_ONBOARDING] ?: false
    }

    suspend fun setActiveModel(modelId: String) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.ACTIVE_MODEL] = modelId
        }
    }

    suspend fun saveDownloadedModels(models: Set<String>) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.DOWNLOADED_MODELS] = models
        }
    }

    suspend fun getDownloadedModels(): Set<String> {
        return downloadedModels.first()
    }

    suspend fun setHapticsEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.HAPTICS_ENABLED] = enabled
        }
    }

    suspend fun setThemeMode(mode: String) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.THEME_MODE] = mode
        }
    }

    suspend fun setOnboardingCompleted(completed: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.HAS_COMPLETED_ONBOARDING] = completed
        }
    }
}