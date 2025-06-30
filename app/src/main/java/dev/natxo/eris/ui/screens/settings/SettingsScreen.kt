package dev.natxo.eris.ui.screens.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dev.natxo.eris.ui.viewmodels.SettingsViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit,
    onNavigateToModelManagement: () -> Unit,
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
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
                // App info section
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // App icon placeholder
                        Card(
                            modifier = Modifier.size(80.dp),
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
                                    style = MaterialTheme.typography.headlineMedium,
                                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = "Eris",
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.Bold
                        )

                        Text(
                            text = "Version 1.6",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            item {
                SettingsSection(title = "AI Models") {
                    SettingsItem(
                        title = "Model Management",
                        subtitle = uiState.activeModelName ?: "No model selected",
                        onClick = onNavigateToModelManagement
                    )
                }
            }

            item {
                SettingsSection(title = "Preferences") {
                    Column {
                        SettingsItem(
                            title = "Theme",
                            subtitle = uiState.themeMode.replaceFirstChar { it.uppercase() }
                        ) {
                            // Theme picker would go here
                        }

                        Divider(modifier = Modifier.padding(horizontal = 16.dp))

                        SettingsSwitchItem(
                            title = "Haptic Feedback",
                            subtitle = "Vibration feedback for interactions",
                            checked = uiState.hapticsEnabled,
                            onCheckedChange = viewModel::setHapticsEnabled
                        )
                    }
                }
            }

            item {
                SettingsSection(title = "System") {
                    Column {
                        SettingsInfoItem(
                            title = "Device",
                            value = uiState.deviceInfo.deviceModel
                        )

                        Divider(modifier = Modifier.padding(horizontal = 16.dp))

                        SettingsInfoItem(
                            title = "Android Version",
                            value = uiState.deviceInfo.androidVersion
                        )

                        Divider(modifier = Modifier.padding(horizontal = 16.dp))

                        SettingsInfoItem(
                            title = "Available RAM",
                            value = "${uiState.deviceInfo.availableRAM / (1024 * 1024 * 1024)}GB"
                        )
                    }
                }
            }

            item {
                SettingsSection(title = "About") {
                    Column {
                        SettingsItem(
                            title = "About Eris",
                            subtitle = "Learn more about the app"
                        ) {
                            // Navigate to about screen
                        }

                        Divider(modifier = Modifier.padding(horizontal = 16.dp))

                        SettingsItem(
                            title = "Privacy Policy",
                            subtitle = "How we protect your data"
                        ) {
                            // Open privacy policy
                        }

                        Divider(modifier = Modifier.padding(horizontal = 16.dp))

                        SettingsItem(
                            title = "Open Source Licenses",
                            subtitle = "Third-party libraries"
                        ) {
                            // Show licenses
                        }
                    }
                }
            }

            item {
                SettingsSection(title = "Data Management") {
                    SettingsItem(
                        title = "Delete All Data",
                        subtitle = "Remove all chats and models",
                        isDestructive = true
                    ) {
                        viewModel.showDeleteAllDataDialog()
                    }
                }
            }
        }
    }

    // Delete confirmation dialog
    if (uiState.showDeleteAllDataDialog) {
        AlertDialog(
            onDismissRequest = { viewModel.hideDeleteAllDataDialog() },
            title = { Text("Delete All Data?") },
            text = { 
                Text("This will permanently delete all your conversations and downloaded models. This action cannot be undone.") 
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteAllData()
                        viewModel.hideDeleteAllDataDialog()
                    }
                ) {
                    Text("Delete All", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { viewModel.hideDeleteAllDataDialog() }
                ) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
private fun SettingsSection(
    title: String,
    content: @Composable () -> Unit
) {
    Column {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
        )

        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            content()
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsItem(
    title: String,
    subtitle: String? = null,
    isDestructive: Boolean = false,
    onClick: () -> Unit = {}
) {
    Card(
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge,
                color = if (isDestructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface
            )

            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }
    }
}

@Composable
private fun SettingsSwitchItem(
    title: String,
    subtitle: String? = null,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge
            )

            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }

        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange
        )
    }
}

@Composable
private fun SettingsInfoItem(
    title: String,
    value: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.bodyLarge
        )

        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}