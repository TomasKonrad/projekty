package cz.mendelu.sportapp.ui.screens.list

import androidx.compose.ui.graphics.Color
import cz.mendelu.sportapp.database.Sport

data class SportActivitiesListUIState(
    val sports: List<SportActivityWithColor>? = null,
    val color: Color = Color.LightGray
)