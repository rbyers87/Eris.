package dev.natxo.eris.ui.screens.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.models.ModelCategory
import dev.natxo.eris.ui.viewmodels.ModelManagementViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModelManagementScreen(
    onNavigateBack: () -> Unit,
    viewModel: ModelManagementViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Model Management") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                // Header
                Column {
                    Text(
                        text = "AI Models",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                    
                    Text(
                        text = "Download and manage AI models for offline use",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
            }

            // Group models by category
            ModelCategory.values().forEach { category ->
                val modelsInCategory = uiState.availableModels.filter { it.category == category }
                if (modelsInCategory.isNotEmpty()) {
                    item {
                        Text(
                            text = category.displayName,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.padding(top = 16.dp, bottom = 8.dp)
                        )
                    }

                    items(modelsInCategory) { model ->
                        ModelManagementCard(
                            model = model,
                            isDownloaded = uiState.downloadedModels.contains(model.id),
                            isDownloading = uiState.downloadingModels.contains(model.id),
                            downloadProgress = uiState.downloadProgress[model.id] ?: 0f,
                            isActive = uiState.activeModelId == model.id,
                            onDownload = { viewModel.downloadModel(model) },
                            onDelete = { viewModel.deleteModel(model) },
                            onSetActive = { viewModel.setActiveModel(model) }
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ModelManagementCard(
    model: AIModel,
    isDownloaded: Boolean,
    isDownloading: Boolean,
    downloadProgress: Float,
    isActive: Boolean,
    onDownload: () -> Unit,
    onDelete: () -> Unit,
    onSetActive: () -> Unit
) {
    var showDeleteDialog by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = if (isActive) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surface
            }
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = model.displayName,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )

                        if (isActive) {
                            AssistChip(
                                onClick = { },
                                label = { Text("Active") },
                                enabled = false
                            )
                        }
                    }

                    Text(
                        text = model.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 4.dp)
                    )

                    Row(
                        modifier = Modifier.padding(top = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        AssistChip(
                            onClick = { },
                            label = { Text(model.parameterCount) },
                            enabled = false
                        )
                        
                        AssistChip(
                            onClick = { },
                            label = { Text(model.quantization) },
                            enabled = false
                        )
                        
                        AssistChip(
                            onClick = { },
                            label = { Text("${model.estimatedSize / (1024 * 1024)}MB") },
                            enabled = false
                        )
                    }
                }

                Column(
                    horizontalAlignment = Alignment.End,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    when {
                        isDownloading -> {
                            CircularProgressIndicator(
                                progress = downloadProgress,
                                modifier = Modifier.size(24.dp)
                            )
                        }
                        isDownloaded -> {
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                if (!isActive) {
                                    TextButton(onClick = onSetActive) {
                                        Text("Activate")
                                    }
                                }
                                
                                IconButton(onClick = { showDeleteDialog = true }) {
                                    Icon(
                                        imageVector = Icons.Default.Delete,
                                        contentDescription = "Delete",
                                        tint = MaterialTheme.colorScheme.error
                                    )
                                }
                            }
                        }
                        else -> {
                            IconButton(onClick = onDownload) {
                                Icon(
                                    imageVector = Icons.Default.Download,
                                    contentDescription = "Download"
                                )
                            }
                        }
                    }
                }
            }

            if (isDownloading) {
                Column(
                    modifier = Modifier.padding(top = 12.dp)
                ) {
                    LinearProgressIndicator(
                        progress = downloadProgress,
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    Text(
                        text = "Downloading... ${(downloadProgress * 100).toInt()}%",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
        }
    }

    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("Delete Model?") },
            text = { 
                Text("This will remove ${model.displayName} from your device. You can download it again later.") 
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        onDelete()
                        showDeleteDialog = false
                    }
                ) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { showDeleteDialog = false }
                ) {
                    Text("Cancel")
                }
            }
        )
    }
}