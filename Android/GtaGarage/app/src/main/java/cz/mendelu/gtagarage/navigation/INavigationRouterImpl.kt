package cz.mendelu.gtagarage.navigation

import androidx.navigation.NavController
import androidx.navigation.NavGraph.Companion.findStartDestination

class INavigationRouterImpl(private val navController: NavController): INavigationRouter {
    private fun navigateToTopLevelDestination(route: Any) {
        navController.navigate(route) {
            launchSingleTop = true
            restoreState = true
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
        }
    }

    override fun navigateToOwnedGarageList() {
        navigateToTopLevelDestination(ScreenDestination.OwnedGaragesList)
    }

    override fun navigateToGarageList() {
        navController.navigate(ScreenDestination.GarageList){
            launchSingleTop = true
        }
    }

    override fun navigateToGarageDetail(garageId: String) {
        navController.navigate(ScreenDestination.GarageDetail(garageId)){
            launchSingleTop = true
        }
    }

    override fun navigateToCarsInGarage(garageId: String) {
        navController.navigate(ScreenDestination.CarsInGarage(garageId)){
            launchSingleTop = true
        }
    }

    override fun navigateToMap() {
        navigateToTopLevelDestination(ScreenDestination.Map)
    }

    override fun navigateToStatistics() {
        navigateToTopLevelDestination(ScreenDestination.Statistics)
    }

    override fun returnBack() {
        if (navController.previousBackStackEntry != null) {
            navController.popBackStack()
        }
    }

    override fun navigateToAddEditCar(garageId: String, carId: String?) {
        navController.navigate(ScreenDestination.AddEditCar(garageId = garageId, carId = carId)) {
            launchSingleTop = true
        }
    }

    override fun navigateToCarDetail(carId: String) {
        navController.navigate(ScreenDestination.CarDetail(carId = carId)) {
            launchSingleTop = true
        }
    }
}