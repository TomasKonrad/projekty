package cz.mendelu.sportapp.ui.screens.list

import android.util.Log
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import cz.mendelu.sportapp.R
import cz.mendelu.sportapp.database.Sport
import cz.mendelu.sportapp.navigation.INavigationRouter
import cz.mendelu.sportapp.ui.screens.list.SportActivitiesListUIState
import cz.mendelu.sportapp.ui.screens.list.SportActivitiesListViewModel
import cz.mendelu.sportapp.ui.screens.elements.BaseScreen
import cz.mendelu.sportapp.ui.screens.elements.PlaceholderScreenContent
import cz.mendelu.sportapp.ui.theme.Dimens.basicMargin
import cz.mendelu.sportapp.ui.theme.Dimens.halfMargin
import cz.mendelu.sportapp.ui.theme.scrimLight

@Composable
fun SportActivitiesListScreen(
    navigationRouter: INavigationRouter,
    viewModel: SportActivitiesListViewModel = hiltViewModel()
) {
    val state = viewModel.sportActivitiesListUIState.collectAsStateWithLifecycle()

    BaseScreen(
        topBarText = stringResource(R.string.top_bar_list_of_activities),
        actions = {
            IconButton(
                onClick = {
                    navigationRouter.navigateToSportActivitiesStatistics(null)
                }
            ) {
                Icon(
                    imageVector = Icons.Default.BarChart,
                    contentDescription = null
                )
            }
        },
        floatingActionButton = {
            FloatingActionButton(onClick = {
                navigationRouter.navigateToAddEditSportActivity(null)
            }) {
                Icon(imageVector = Icons.Default.Add, contentDescription = null)
            }
        }, placeholderScreenContent = if (state.value.sports.isNullOrEmpty()) {
            PlaceholderScreenContent(
                image = R.drawable.no_sports_activities,
                text = R.string.you_have_no_sports_activity
            )
        } else {
            null
        },
        content = { paddingValues ->
            SportActivityListScreenContent(
                paddingValues = paddingValues,
                navigationRouter = navigationRouter,
                state = state.value
            )
        }
    )

}

@Composable
fun SportActivityListScreenContent(
    paddingValues: PaddingValues,
    navigationRouter: INavigationRouter,
    state: SportActivitiesListUIState
) {
    if (!state.sports.isNullOrEmpty()){
        LazyColumn(
            modifier = Modifier.padding(paddingValues)
        ) {
            state.sports.forEach { sportColor ->
                item {
                    SportColumn(
                        sportWithColor = sportColor,
                        onClick = {
                            navigationRouter.navigateToSportActivityDetail(sportColor.sport.id!!)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun SportColumn(
    sportWithColor: SportActivityWithColor,
    onClick: () -> Unit
) {
    OutlinedCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(
                onClick = {
                    onClick()
                }
            ).padding(
                horizontal = basicMargin,
                vertical = halfMargin
            ),
        border = BorderStroke(
            width = 2.dp,
            color = MaterialTheme.colorScheme.outlineVariant
        )
    ) {
        Row(
            modifier = Modifier.padding(basicMargin),
            verticalAlignment = Alignment.CenterVertically
        ){
            Surface(
                shape = CircleShape,
                color = sportWithColor.color
            ) {
                Icon(
                    imageVector = sportWithColor.sport.typeOfActivity.icon,
                    contentDescription = null,
                    modifier = Modifier.padding(basicMargin),
                    tint = scrimLight
                )
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = basicMargin)
            ) {
                Text(text = sportWithColor.sport.title, style = MaterialTheme.typography.titleMedium)
                Text(text = "${sportWithColor.sport.place} (${sportWithColor.sport.typeOfActivity.type})",
                    style = MaterialTheme.typography.bodyMedium)
            }

            Text(
                text = "${sportWithColor.sport.durationInMinutes} minut",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}