package cz.mendelu.gtagarage.ui.screens.OwnedGaragesList

import android.util.Log
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavDestination
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.OwnedGarage
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.BottomNavigationMenu
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.screens.elements.Placeholder.PlaceholderScreenContent
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OwnedGaragesListScreen(
    navigationRouter: INavigationRouter,
    currentDestination: NavDestination?,
    viewModel: OwnedGaragesListViewModel = hiltViewModel()
){
    val state = viewModel.ownedGarageListUIState.collectAsStateWithLifecycle()

    BaseScreen(
        topBarText = stringResource(R.string.owned_garages_list),
        floatingActionButton = {
            FloatingActionButton(onClick = {
                navigationRouter.navigateToGarageList()
            }) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null
                )
            }
        },
        bottomBar = {
            BottomNavigationMenu(
                currentDestination = currentDestination,
                onMapClick = { navigationRouter.navigateToMap() },
                onOwnedGaragesClick = { navigationRouter.navigateToOwnedGarageList() },
                onStatisticsClick = { navigationRouter.navigateToStatistics() }
            )
        },
        placeholderScreenContent = when {
            state.value.isOfflineFirstLaunch -> PlaceholderScreenContent(
                lottieAnimation = "Animations/no_internet_cat.json",
                text = R.string.no_internet_first_launch
            )
            state.value.ownedGarages.isNullOrEmpty() -> PlaceholderScreenContent(
                lottieAnimation = "Animations/no_data.json",
                text = R.string.no_owned_garages
            )
            else -> null
        },
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                OwnedGaragesListScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    navigationRouter = navigationRouter,
                    appVersion = state.value.appVersion
                )
            }
        }
    )
}

@Composable
fun OwnedGaragesListScreenContent(
    paddingValues: PaddingValues,
    state: OwnedGaragesListUIState,
    navigationRouter: INavigationRouter,
    appVersion: String
) {
    if (!state.ownedGarages.isNullOrEmpty()){
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(basicMargin)
                .consumeWindowInsets(paddingValues),
            contentPadding = paddingValues,
            verticalArrangement = Arrangement.spacedBy(halfMargin)
        ) {
            state.ownedGarages.forEach { ownedGarages ->
                item {
                    GarageCard(
                        ownedGarage = ownedGarages,
                        onClick = {
                            navigationRouter.navigateToCarsInGarage(ownedGarages.garageId)
                        }
                    )

                }
            }
            item {
                Text(
                    text = "Version v$appVersion",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = halfMargin),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
fun GarageCard(
    ownedGarage: OwnedGarage,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(basicMargin),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        border = BorderStroke(
            width = 0.5.dp,
            color = MaterialTheme.colorScheme.outlineVariant
        )
    ) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .height(64.dp)
                    .background(MaterialTheme.colorScheme.primary)
            )
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = basicMargin, vertical = halfMargin)
            ) {
                Text(
                    text = ownedGarage.garageName,
                    style = MaterialTheme.typography.titleSmall
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(14.dp)
                        )
                        Text(
                            text = ownedGarage.garageLocationName,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = MaterialTheme.colorScheme.primaryContainer
                    ) {
                        Text(
                            text = stringResource(R.string.max_capacity_value, ownedGarage.garageCapacity),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onPrimaryContainer,
                            modifier = Modifier.padding(horizontal = halfMargin, vertical = 2.dp)
                        )
                    }
                }
            }
        }
    }
}