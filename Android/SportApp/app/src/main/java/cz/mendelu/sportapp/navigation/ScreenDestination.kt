package cz.mendelu.sportapp.navigation

import kotlinx.serialization.Serializable

interface ScreenDestination {
    @Serializable
    data object SportActivitiesList : ScreenDestination
    @Serializable
    data class AddEditSportActivity(val id: Long? = null)
    @Serializable
    data class SportActivityDetail(val id: Long)
    @Serializable
    data class SportActivitiesStatistics(val id: Long? = null)
}