package cz.mendelu.sportapp.navigation

import androidx.navigation.NavController

class NavigationRouterImpl(private val navController: NavController) : INavigationRouter {
    override fun navigateToAddEditSportActivity(id: Long?) {
        navController.navigate(ScreenDestination.AddEditSportActivity(id))
    }

    override fun navigateToSportActivityDetail(id: Long) {
        navController.navigate(ScreenDestination.SportActivityDetail(id))
    }

    override fun navigateToSportActivitiesStatistics(id: Long?) {
        navController.navigate(ScreenDestination.SportActivitiesStatistics(id))
    }

    override fun returnBack() {
        if (navController.previousBackStackEntry != null) {
            navController.popBackStack()
        }
    }
}