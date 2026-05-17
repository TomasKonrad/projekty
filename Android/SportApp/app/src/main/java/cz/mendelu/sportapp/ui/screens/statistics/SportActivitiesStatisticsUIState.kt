package cz.mendelu.sportapp.ui.screens.statistics

import cz.mendelu.sportapp.database.SportActivity

data class SportActivitiesStatisticsUIState(
    val loading: Boolean = true,
    val count: Int = 0,
    val totalMinutes: Int = 0,
    val mostCommonActivity: SportActivity? = null
)
