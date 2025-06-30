package dev.natxo.eris.data.models

import android.app.ActivityManager
import android.content.Context
import android.os.Build

data class DeviceInfo(
    val deviceModel: String,
    val androidVersion: String,
    val totalRAM: Long,
    val availableRAM: Long,
    val hasNeuralProcessing: Boolean,
    val supportedABIs: List<String>
) {
    companion object {
        fun fromContext(context: Context): DeviceInfo {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memoryInfo = ActivityManager.MemoryInfo()
            activityManager.getMemoryInfo(memoryInfo)
            
            return DeviceInfo(
                deviceModel = "${Build.MANUFACTURER} ${Build.MODEL}",
                androidVersion = Build.VERSION.RELEASE,
                totalRAM = memoryInfo.totalMem,
                availableRAM = memoryInfo.availMem,
                hasNeuralProcessing = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P,
                supportedABIs = Build.SUPPORTED_ABIS.toList()
            )
        }
    }
    
    fun getCompatibilityForModel(model: AIModel): ModelCompatibility {
        val requiredRAM = model.minimumRAM
        val safetyMargin = 1024 * 1024 * 1024L // 1GB safety margin
        
        return when {
            totalRAM >= requiredRAM + safetyMargin * 2 -> ModelCompatibility.RECOMMENDED
            totalRAM >= requiredRAM + safetyMargin -> ModelCompatibility.COMPATIBLE
            totalRAM >= requiredRAM -> ModelCompatibility.RISKY
            else -> ModelCompatibility.NOT_RECOMMENDED
        }
    }
}