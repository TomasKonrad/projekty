package cz.mendelu.gtagarage.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import cz.mendelu.gtagarage.ui.screens.AddEditCar.AddEditCarScreen
import cz.mendelu.gtagarage.ui.screens.CarDetail.CarDetailScreen
import cz.mendelu.gtagarage.ui.screens.GarageDetail.GarageDetailScreen
import cz.mendelu.gtagarage.ui.screens.GarageList.GarageListScreen
import cz.mendelu.gtagarage.ui.screens.Map.MapScreen
import cz.mendelu.gtagarage.ui.screens.OwnedCarsList.CarsInGarageScreen
import cz.mendelu.gtagarage.ui.screens.OwnedGaragesList.OwnedGaragesListScreen
import cz.mendelu.gtagarage.ui.screens.StatisticsScreen.StatisticScreen

@Composable
fun GarageNavGraph(
    startDestination: ScreenDestination,
    navHostController: NavHostController = rememberNavController(),
    navRouter: INavigationRouter = remember {
        INavigationRouterImpl(navHostController)
    },
){
    val navBackStackEntry by navHostController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    NavHost(
        navController = navHostController,
        startDestination = startDestination
    ) {
        composable<ScreenDestination.OwnedGaragesList> {
            OwnedGaragesListScreen(
                navigationRouter = navRouter,
                currentDestination = currentDestination
            )
        }

        composable<ScreenDestination.GarageList> {
            GarageListScreen(
                navigationRouter = navRouter
            )
        }

        composable<ScreenDestination.GarageDetail> {
            GarageDetailScreen(
                navigationRouter = navRouter,
            )
        }

        composable<ScreenDestination.CarsInGarage> {
            CarsInGarageScreen(
                navigationRouter = navRouter,
            )
        }

        composable<ScreenDestination.Map>{
            MapScreen(
                navigationRouter = navRouter,
                currentDestination = currentDestination
            )
        }

        composable<ScreenDestination.Statistics>{
            StatisticScreen(
                navigationRouter = navRouter,
                currentDestination = currentDestination
            )
        }

        composable<ScreenDestination.AddEditCar> {
            AddEditCarScreen(
                navigationRouter = navRouter
            )
        }

        composable<ScreenDestination.CarDetail> {
            CarDetailScreen(
                navigationRouter = navRouter,
            )
        }
    }
}
