package cz.mendelu.gtagarage.ui.screens.GarageList

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.screens.elements.Placeholder.PlaceholderScreenContent
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin

@Composable
fun GarageListScreen(
    navigationRouter: INavigationRouter,
    viewModel: GarageListViewModel = hiltViewModel(),
){
    val state = viewModel.garageListUIState.collectAsStateWithLifecycle()

    if(state.value.garageSaved){
        LaunchedEffect(state.value) {
            navigationRouter.returnBack()
        }
    }

    BaseScreen(
        topBarText = stringResource(R.string.existing_garages),
        onBackClick = {
            navigationRouter.returnBack()
        },
        placeholderScreenContent = when {
            state.value.isOfflineFirstLaunch -> PlaceholderScreenContent(
                lottieAnimation = "Animations/no_internet_cat.json",
                text = R.string.no_internet_first_launch
            )
            state.value.garages.isNullOrEmpty() -> PlaceholderScreenContent(
                lottieAnimation = "Animations/no_data.json",
                text = R.string.no_data
            )
            else -> null
        },
        snackbarMessage = if (state.value.showErrorSnackbar) {
            stringResource(R.string.error_no_internet)
        } else null,
        onSnackbarDismiss = { viewModel.clearError() },
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                GarageListScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    onDetailGarageClick = { garage ->
                        navigationRouter.navigateToGarageDetail(garage.id)
                    },
                    onAddGarageClick = { garage ->
                        viewModel.addGarageToOwned(garage)
                    }
                )
            }
        }
    )
}

@Composable
fun GarageListScreenContent(
    paddingValues: PaddingValues,
    state: GarageListUIState,
    onDetailGarageClick: (Garage) -> Unit,
    onAddGarageClick: (Garage) -> Unit
) {
    if (!state.garages.isNullOrEmpty()){
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .navigationBarsPadding()
                .padding(horizontal = basicMargin),
            verticalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            state.garages.forEach { garage ->
                item{
                    GarageListItem(
                        garage = garage,
                        isAlreadyOwned = state.ownedGarageIds.contains(garage.id),
                        onDetailGarageClick = {
                            onDetailGarageClick(garage)
                        },
                        onAddGarageClick = {
                            onAddGarageClick(garage)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun GarageListItem(
    garage: Garage,
    isAlreadyOwned: Boolean,
    onDetailGarageClick: () -> Unit,
    onAddGarageClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    ElevatedCard(
        modifier = modifier
            .fillMaxWidth(),
        shape = RoundedCornerShape(basicMargin)
    ) {
        Column(
            modifier= Modifier.fillMaxWidth()
        ){
            Box(
                modifier = Modifier
                    .fillMaxWidth()
            ){
                if (garage.imagePath.isNotBlank()) {
                    AsyncImage(
                        model = garage.imagePath,
                        contentDescription = garage.name,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .height(180.dp)
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                    )
                }
            }
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(basicMargin),
                verticalArrangement = Arrangement.spacedBy(basicMargin)
            ) {
                Column(
                    verticalArrangement = Arrangement.spacedBy(halfMargin)
                ) {
                    Text(
                        text = garage.name,
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(
                        text = garage.locationName,
                        style = MaterialTheme.typography.labelMedium
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(basicMargin)
                ){
                    OutlinedButton(
                        onClick = onDetailGarageClick,
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(stringResource(R.string.see_detail))
                    }

                    Button(
                        onClick = onAddGarageClick,
                        modifier = Modifier.weight(1.5f),
                        enabled = !isAlreadyOwned
                    ) {
                        Text(stringResource(
                            if (isAlreadyOwned) R.string.garage_already_owned
                            else R.string.add_to_owned
                        ))
                    }
                }
            }
        }
    }
}