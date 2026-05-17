package cz.mendelu.sportapp.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import cz.mendelu.sportapp.ui.screens.addEdit.AddEditSportActivityScreen
import cz.mendelu.sportapp.ui.screens.detail.SportActivityDetailScreen
import cz.mendelu.sportapp.ui.screens.detail.SportActvityDetailViewModel
import cz.mendelu.sportapp.ui.screens.list.SportActivitiesListScreen
import cz.mendelu.sportapp.ui.screens.statistics.SportActivitiesStatisticsScreen

@Composable
fun SportNavGraph(
    startDestination: ScreenDestination,
    navHostController: NavHostController = rememberNavController(),
    navRouter: INavigationRouter = remember{
        NavigationRouterImpl(navHostController)
    }
){
    NavHost(
        navController = navHostController,
        startDestination = startDestination
    ) {
        composable<ScreenDestination.SportActivitiesList>{
            SportActivitiesListScreen(navigationRouter = navRouter)
        }

        composable<ScreenDestination.AddEditSportActivity>{ backStackEntry ->
            val destination: ScreenDestination.AddEditSportActivity = backStackEntry.toRoute()
            AddEditSportActivityScreen(
                navigationRouter = navRouter,
                id = destination.id
            )
        }

        composable<ScreenDestination.SportActivityDetail>{
            val viewModel: SportActvityDetailViewModel = hiltViewModel()
            SportActivityDetailScreen(
                navigationRouter = navRouter,
                actions = viewModel
            )
        }

        composable<ScreenDestination.SportActivitiesStatistics>{
            SportActivitiesStatisticsScreen(
                navigationRouter = navRouter
            )
        }
    }
}