package cz.mendelu.gtagarage.ui.screens.OwnedCarsList

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
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.ImageNotSupported
import androidx.compose.material3.Button
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.DeleteConfirmDialog
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.screens.elements.Placeholder.PlaceholderScreenContent
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.quarterMargin

@Composable
fun CarsInGarageScreen(
    navigationRouter: INavigationRouter,
    viewModel: OwnedCarsListViewModel = hiltViewModel()
) {
    val state = viewModel.ownedCarsListUIState.collectAsStateWithLifecycle()
    val isFull = viewModel.isGarageFull()

    LaunchedEffect(state.value.garageDeleted) {
        if (state.value.garageDeleted) {
            navigationRouter.returnBack()
        }
    }

    if (state.value.showDeleteGarageDialog) {
        DeleteConfirmDialog(
            title = stringResource(R.string.delete_garage_title),
            message = stringResource(R.string.delete_garage_message),
            onConfirm = { viewModel.onDeleteGarageConfirm() },
            onDismiss = { viewModel.onDeleteGarageDismiss() }
        )
    }

    BaseScreen(
        topBarText = stringResource(R.string.owned_cars),
        onBackClick = {
            navigationRouter.returnBack()
        },
        actions = {
            state.value.garage?.let { garage ->
                GarageCapacityHeader(
                  garage = garage,
                  carsCount = state.value.ownedCars?.size ?: 0,
                )
            }
            IconButton(onClick = { viewModel.onDeleteGarageClick() }) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = null
                )
            }
        },
        snackbarMessage = when {
            state.value.showGarageFullSnackbar -> stringResource(R.string.garage_full_message)
            state.value.showErrorSnackbar -> stringResource(R.string.error_no_internet)
            else -> null
        },
        onSnackbarDismiss = {
            viewModel.clearGarageFullSnackbar()
            viewModel.clearError()
        },
        floatingActionButton = {
            FloatingActionButton(
                modifier = Modifier.navigationBarsPadding(),
                onClick = {
                    if (isFull) {
                        viewModel.onGarageFullClick()
                    } else {
                        navigationRouter.navigateToAddEditCar(state.value.garageId)
                    }
                },
                containerColor = if (isFull) {
                    MaterialTheme.colorScheme.surfaceVariant
                } else {
                    MaterialTheme.colorScheme.primaryContainer
                }
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null,
                    tint = if (isFull) {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    } else {
                        MaterialTheme.colorScheme.onPrimaryContainer
                    }
                )
            }
        },
        placeholderScreenContent = if (state.value.ownedCars.isNullOrEmpty()) {
            PlaceholderScreenContent(
                lottieAnimation = "Animations/car.json",
                text = R.string.no_owned_cars
            )
        } else {
            null
        },
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                OwnedCarsListScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    onDetailCarClick = { car ->
                        navigationRouter.navigateToCarDetail(car.id)
                    },
                )
            }
        }
    )
}

@Composable
fun OwnedCarsListScreenContent(
    paddingValues: PaddingValues,
    state: OwnedCarsListUIState,
    onDetailCarClick: (Car) -> Unit,
) {
    if (!state.ownedCars.isNullOrEmpty()){
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .navigationBarsPadding()
                .padding(horizontal = basicMargin),
            verticalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            state.ownedCars.forEach { car ->
                item{
                    CarListItem(
                        car = car,
                        onDetailCarClick = {
                            onDetailCarClick(car)
                        }
                    )


                }
            }
        }
    }
}

@Composable
fun CarListItem(
    car: Car,
    onDetailCarClick: () -> Unit,
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
                if (car.imagePath.isNotBlank()) {
                    AsyncImage(
                        model = car.imagePath,
                        contentDescription = car.name,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                            .height(220.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(halfMargin)
                        ) {
                            Icon(
                                imageVector = Icons.Default.ImageNotSupported,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = stringResource(R.string.no_image),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
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
                        text = "${car.brand} ${car.name}",
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(
                        text = car.vehicleClass.type,
                        style = MaterialTheme.typography.labelMedium
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(basicMargin)
                ){
                    Button(
                        onClick = onDetailCarClick,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(stringResource(R.string.see_detail))
                    }
                }
            }
        }
    }
}

@Composable
fun GarageCapacityHeader(
    garage: Garage,
    carsCount: Int,
    modifier: Modifier = Modifier
) {
    val isFull = carsCount >= garage.capacity

    Surface(
        shape = RoundedCornerShape(basicMargin),
        color = if (isFull) {
            MaterialTheme.colorScheme.errorContainer
        } else {
            MaterialTheme.colorScheme.secondaryContainer
        },
        modifier = modifier
            .wrapContentWidth()
            .padding(vertical = halfMargin)
    ) {
        Row(
            modifier = Modifier
                .padding(horizontal = halfMargin),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(quarterMargin)
        ) {
            Icon(
                imageVector = Icons.Default.DirectionsCar,
                contentDescription = null,
                tint = if (isFull) {
                    MaterialTheme.colorScheme.onErrorContainer
                } else {
                    MaterialTheme.colorScheme.onSecondaryContainer
                }
            )
            Text(
                text = "$carsCount / ${garage.capacity}",
                style = MaterialTheme.typography.bodyMedium,
                color = if (isFull) {
                    MaterialTheme.colorScheme.onErrorContainer
                } else {
                    MaterialTheme.colorScheme.onSecondaryContainer
                }
            )
        }
    }
}