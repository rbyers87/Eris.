package dev.natxo.eris.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import dev.natxo.eris.ui.screens.chat.ChatScreen
import dev.natxo.eris.ui.screens.home.HomeScreen
import dev.natxo.eris.ui.screens.onboarding.OnboardingScreen
import dev.natxo.eris.ui.screens.settings.SettingsScreen
import dev.natxo.eris.ui.screens.settings.ModelManagementScreen
import dev.natxo.eris.ui.viewmodels.MainViewModel

@Composable
fun ErisNavigation(
    navController: NavHostController = rememberNavController(),
    mainViewModel: MainViewModel = hiltViewModel()
) {
    val hasCompletedOnboarding by mainViewModel.hasCompletedOnboarding.collectAsState()

    NavHost(
        navController = navController,
        startDestination = if (hasCompletedOnboarding) "home" else "onboarding"
    ) {
        composable("onboarding") {
            OnboardingScreen(
                onOnboardingComplete = {
                    navController.navigate("home") {
                        popUpTo("onboarding") { inclusive = true }
                    }
                }
            )
        }

        composable("home") {
            HomeScreen(
                onNavigateToChat = { threadId ->
                    navController.navigate("chat/$threadId")
                },
                onNavigateToSettings = {
                    navController.navigate("settings")
                }
            )
        }

        composable("chat/{threadId}") { backStackEntry ->
            val threadId = backStackEntry.arguments?.getString("threadId") ?: ""
            ChatScreen(
                threadId = threadId,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable("settings") {
            SettingsScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToModelManagement = {
                    navController.navigate("model_management")
                }
            )
        }

        composable("model_management") {
            ModelManagementScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}