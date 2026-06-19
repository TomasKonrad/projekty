package cz.mendelu.gtagarage.navigation

import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination

data class BottomNavItem(
    val label: String,
    val icon: ImageVector,
    val onClick: () -> Unit,
    val isSelected: (NavDestination?) -> Boolean
)
