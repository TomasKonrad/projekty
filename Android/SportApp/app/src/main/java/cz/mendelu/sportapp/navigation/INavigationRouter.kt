package cz.mendelu.sportapp.navigation

interface INavigationRouter {
    fun navigateToAddEditSportActivity(id: Long?)
    fun navigateToSportActivityDetail(id: Long)
    fun navigateToSportActivitiesStatistics(id: Long?)
    fun returnBack()
}