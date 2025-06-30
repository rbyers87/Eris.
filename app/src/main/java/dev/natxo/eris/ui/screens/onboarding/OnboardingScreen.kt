package dev.natxo.eris.ui.screens.onboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.WifiOff
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dev.natxo.eris.R
import dev.natxo.eris.data.models.AIModel
import dev.natxo.eris.data.models.ModelCategory
import dev.natxo.eris.ui.viewmodels.OnboardingViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingScreen(
    onOnboardingComplete: () -> Unit,
    viewModel: OnboardingViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    LaunchedEffect(uiState.isOnboardingComplete) {
        if (uiState.isOnboardingComplete) {
            onOnboardingComplete()
        }
    }

    when (uiState.currentStep) {
        OnboardingStep.WELCOME -> {
            WelcomeStep(
                onNext = { viewModel.nextStep() }
            )
        }
        OnboardingStep.MODEL_SELECTION -> {
            ModelSelectionStep(
                availableModels = uiState.availableModels,
                selectedModel = uiState.selectedModel,
                onModelSelected = { viewModel.selectModel(it) },
                onNext = { viewModel.nextStep() }
            )
        }
        OnboardingStep.DOWNLOAD -> {
            DownloadStep(
                selectedModel = uiState.selectedModel!!,
                downloadProgress = uiState.downloadProgress,
                isDownloading = uiState.isDownloading,
                downloadError = uiState.downloadError,
                onStartDownload = { viewModel.startDownload() },
                onRetryDownload = { viewModel.retryDownload() },
                onComplete = { viewModel.completeOnboarding() }
            )
        }
    }
}

@Composable
private fun WelcomeStep(
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // App icon placeholder
            Card(
                modifier = Modifier.size(100.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "E",
                        style = MaterialTheme.typography.headlineLarge,
                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Text(
                text = "Welcome to Eris",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )

            Text(
                text = "Chat with AI models privately on your device",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Column(
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            FeatureItem(
                icon = Icons.Default.Lock,
                title = "100% Private",
                description = "Your conversations never leave your device"
            )

            FeatureItem(
                icon = Icons.Default.Speed,
                title = "Lightning Fast",
                description = "Powered by on-device AI processing"
            )

            FeatureItem(
                icon = Icons.Default.WifiOff,
                title = "Works Offline",
                description = "No internet connection required after setup"
            )

            FeatureItem(
                icon = Icons.Default.Memory,
                title = "Local Models",
                description = "Download and manage AI models on device"
            )
        }

        Button(
            onClick = onNext,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Get Started")
        }
    }
}

@Composable
private fun FeatureItem(
    icon: ImageVector,
    title: String,
    description: String
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier.size(24.dp)
        )

        Column {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun ModelSelectionStep(
    availableModels: List<AIModel>,
    selectedModel: AIModel?,
    onModelSelected: (AIModel) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp)
    ) {
        Text(
            text = "Choose Your Model",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Text(
            text = "Select an AI model to download and start chatting",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        LazyColumn(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(availableModels) { model ->
                ModelCard(
                    model = model,
                    isSelected = selectedModel?.id == model.id,
                    onClick = { onModelSelected(model) }
                )
            }
        }

        Button(
            onClick = onNext,
            modifier = Modifier.fillMaxWidth(),
            enabled = selectedModel != null
        ) {
            Text("Download Model")
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ModelCard(
    model: AIModel,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surface
            }
        ),
        border = if (isSelected) {
            CardDefaults.outlinedCardBorder().copy(
                brush = null,
                width = 2.dp
            )
        } else null
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
                    Text(
                        text = model.displayName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    
                    Text(
                        text = model.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }

                if (isSelected) {
                    Icon(
                        imageVector = Icons.Default.Lock, // Using Lock as placeholder for checkmark
                        contentDescription = "Selected",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(24.dp)
                    )
                }
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
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
    }
}

@Composable
private fun DownloadStep(
    selectedModel: AIModel,
    downloadProgress: Float,
    isDownloading: Boolean,
    downloadError: String?,
    onStartDownload: () -> Unit,
    onRetryDownload: () -> Unit,
    onComplete: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // Progress indicator
            Box(
                modifier = Modifier.size(150.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(
                    progress = downloadProgress,
                    modifier = Modifier.fillMaxSize(),
                    strokeWidth = 8.dp
                )
                
                Text(
                    text = if (isDownloading) "${(downloadProgress * 100).toInt()}%" else "Ready",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
            }

            Text(
                text = when {
                    downloadError != null -> "Download Failed"
                    downloadProgress >= 1f -> "Download Complete!"
                    isDownloading -> "Downloading Model"
                    else -> "Ready to Download"
                },
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )

            Text(
                text = when {
                    downloadError != null -> downloadError
                    downloadProgress >= 1f -> "Successfully downloaded ${selectedModel.displayName}. You're ready to start chatting!"
                    isDownloading -> "Please wait while we download ${selectedModel.displayName}. This may take a few minutes."
                    else -> "You're about to download ${selectedModel.displayName}"
                },
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            if (downloadError != null) {
                Text(
                    text = downloadError,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.error,
                    textAlign = TextAlign.Center
                )
            }
        }

        when {
            downloadError != null -> {
                Button(
                    onClick = onRetryDownload,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Retry Download")
                }
            }
            downloadProgress >= 1f -> {
                Button(
                    onClick = onComplete,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Start Chatting")
                }
            }
            isDownloading -> {
                Button(
                    onClick = { },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = false
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Downloading...")
                }
            }
            else -> {
                Button(
                    onClick = onStartDownload,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Start Download")
                }
            }
        }
    }
}