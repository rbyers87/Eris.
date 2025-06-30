package dev.natxo.eris.data.models

data class AIModel(
    val id: String,
    val displayName: String,
    val description: String,
    val category: ModelCategory,
    val parameterCount: String,
    val quantization: String,
    val estimatedSize: Long, // in bytes
    val minimumRAM: Long, // in bytes
    val downloadUrl: String,
    val configUrl: String,
    val tokenizerUrl: String
)

enum class ModelCategory(val displayName: String, val icon: String) {
    GENERAL("General Purpose", "cpu"),
    REASONING("Reasoning", "psychology"),
    CODE("Code", "code")
}

enum class ModelCompatibility(val displayName: String, val color: String) {
    RECOMMENDED("Recommended", "green"),
    COMPATIBLE("Compatible", "blue"),
    RISKY("May have issues", "orange"),
    NOT_RECOMMENDED("Not recommended", "red")
}