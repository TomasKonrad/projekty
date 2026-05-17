package cz.mendelu.sportapp.ui.screens.list

import androidx.compose.ui.graphics.Color
import cz.mendelu.sportapp.database.Sport

data class SportActivityWithColor(
    val sport: Sport,
    val color: Color
)
