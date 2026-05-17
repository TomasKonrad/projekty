package cz.mendelu.sportapp.ui.screens.statistics

import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DoDisturb
import androidx.compose.material.icons.filled.QueryStats
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import cz.mendelu.sportapp.R
import cz.mendelu.sportapp.navigation.INavigationRouter
import cz.mendelu.sportapp.ui.screens.elements.BaseScreen
import cz.mendelu.sportapp.ui.theme.Dimens.basicMargin
import cz.mendelu.sportapp.ui.theme.Dimens.halfMargin
import cz.mendelu.sportapp.ui.theme.Dimens.largeMargin

@Composable
fun SportActivitiesStatisticsScreen(
    navigationRouter: INavigationRouter,
    viewModel: SportActivitiesStatisticsViewModel = hiltViewModel()
){
    val state = viewModel.sportActivitiesStatisticsUIState.collectAsStateWithLifecycle()

    BaseScreen(
        topBarText = stringResource(R.string.statistics),
        showLoading = state.value.loading,
        onBackClick = {
            navigationRouter.returnBack()
        },
        content = { paddingValues ->
            SportActivitiesStatisticsScreenContent(
                paddingValues = paddingValues,
                state = state.value,
            )
        }
    )
}

@Composable
fun SportActivitiesStatisticsScreenContent(
    paddingValues: PaddingValues,
    state: SportActivitiesStatisticsUIState
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(
                top = paddingValues.calculateTopPadding() + basicMargin,
                start = basicMargin,
                end = basicMargin,
                bottom = basicMargin
            )
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(basicMargin),
        horizontalAlignment = Alignment.CenterHorizontally
    ){
        Surface(
            shape = CircleShape,
            color = MaterialTheme.colorScheme.primaryContainer,
            modifier = Modifier
                .padding(top = basicMargin, bottom = halfMargin)
                .size(80.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    imageVector = Icons.Default.QueryStats,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp),
                    tint = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }

        Text(
            text = stringResource(R.string.statistic_title),
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.padding(bottom = largeMargin)
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            StatisticCard(
                label = stringResource(R.string.count_activities),
                value = state.count.toString(),
                modifier = Modifier.weight(1f),
            )

            StatisticCard(
                label = stringResource(R.string.total_minutes),
                value = state.totalMinutes.toString(),
                modifier = Modifier.weight(1f),
            )
        }

        StatisticCardImage(
            icon = state.mostCommonActivity?.icon ?: Icons.Default.DoDisturb,
            label = stringResource(R.string.most_common_activity),
            value = state.mostCommonActivity?.type ?: "no most common activity"
        )
    }
}

@Composable
fun StatisticCard(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
    containerColor: Color = MaterialTheme.colorScheme.surfaceVariant
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(containerColor = containerColor),
        shape = MaterialTheme.shapes.medium
    ) {
        Column(
            modifier = Modifier.padding(basicMargin),
            verticalArrangement = Arrangement.spacedBy(halfMargin)
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
        }
    }
}


@Composable
fun StatisticCardImage(
    icon: ImageVector,
    label: String,
    value: String,
    containerColor: Color = MaterialTheme.colorScheme.surfaceVariant
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = containerColor),
        shape = MaterialTheme.shapes.medium
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(basicMargin),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary
            )
            Column {
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = value,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}