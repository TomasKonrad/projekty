package cz.mendelu.gtagarage.ui.screens.CarDetail

import android.icu.text.NumberFormat
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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.Category
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Factory
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.VehicleClass
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.DeleteConfirmDialog
import cz.mendelu.gtagarage.ui.screens.elements.DetailHeaderImage
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import java.util.Locale

@Composable
fun CarDetailScreen(
    navigationRouter: INavigationRouter,
    viewModel: CarDetailViewModel = hiltViewModel()
) {
    val state = viewModel.carDetailUIState.collectAsStateWithLifecycle()
    val car = state.value.car

    if (state.value.showDeleteDialog) {
        DeleteConfirmDialog(
            title = stringResource(R.string.delete_car_dialog_title),
            message = stringResource(R.string.delete_car_dialog_message),
            onConfirm = {
              viewModel.onDeleteConfirm()
            },
            onDismiss = {
                viewModel.onDeleteDismiss()
            }
        )
    }

    LaunchedEffect(state.value.carDeleted) {
        if (state.value.carDeleted) {
            navigationRouter.returnBack()
        }
    }

    BaseScreen(
        topBarText = stringResource(R.string.car_detail),
        onBackClick = {
            navigationRouter.returnBack()
        },
        actions = {
            IconButton(
                onClick = {
                    viewModel.onDeleteClick()
                }
            ) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = null
                )
            }
        },

        floatingActionButton = {
            FloatingActionButton(
                modifier = Modifier.navigationBarsPadding(),
                onClick = {
                    car?.let {
                        navigationRouter.navigateToAddEditCar(
                            garageId = car.garageId,
                            carId = car.id
                        )
                    }
            }) {
                Icon(
                    imageVector = Icons.Default.Edit,
                    contentDescription = null
                )
            }
        },
        snackbarMessage = if (state.value.showErrorSnackbar) {
            stringResource(R.string.error_no_internet)
        } else null,
        onSnackbarDismiss = { viewModel.clearError() },
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                CarDetailScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                )
            }
        }
    )
}

@Composable
fun CarDetailScreenContent(
    paddingValues: PaddingValues,
    state: CarDetailUIState
) {
    state.car?.let { car ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .navigationBarsPadding()
                .padding(horizontal = basicMargin, vertical = basicMargin),
            verticalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            DetailHeaderImage(imagePath = car.imagePath)

            CarNameSection(
                name = car.name,
            )

            CarSpecsCard(
                brand = car.brand,
                vehicleClass = car.vehicleClass.type,
                maxSpeed = car.maxSpeed,
                purchasePrice = car.purchasePrice
            )

            if (car.description.isNotEmpty()) {
                CarDescriptionCard(description = car.description)
            }
        }
    }
}

@Composable
fun CarNameSection(
    name: String,
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(halfMargin)
    ) {
        Text(
            text = name,
            style = MaterialTheme.typography.titleLarge
        )
    }
}

@Composable
fun CarSpecsCard(
    brand: String,
    vehicleClass: String,
    maxSpeed: Int,
    purchasePrice: Double
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(basicMargin),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(basicMargin)
        ) {
            CarSpecRow(
                icon = Icons.Default.Factory,
                label = stringResource(R.string.brand),
                value = brand,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
            )
            HorizontalDivider(
                modifier = Modifier.padding(vertical = halfMargin),
                color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.2f)
            )
            CarSpecRow(
                icon = Icons.Default.Category,
                label = stringResource(R.string.vehicle_class),
                value = vehicleClass,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
            )
            HorizontalDivider(
                modifier = Modifier.padding(vertical = halfMargin),
                color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.2f)
            )
            CarSpecRow(
                icon = Icons.Default.Speed,
                label = stringResource(R.string.max_speed),
                value = stringResource(R.string.mph_value, maxSpeed),
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
            )
            HorizontalDivider(
                modifier = Modifier.padding(vertical = halfMargin),
                color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.2f)
            )
            CarSpecRow(
                icon = Icons.Default.AttachMoney,
                label = stringResource(R.string.purchase_price),
                value = NumberFormat.getCurrencyInstance(Locale.US).format(purchasePrice),
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
            )
        }
    }
}

@Composable
fun CarSpecRow(
    icon: ImageVector,
    label: String,
    value: String,
    contentColor: Color = MaterialTheme.colorScheme.onSurfaceVariant
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(halfMargin)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = contentColor,
            modifier = Modifier.size(20.dp)
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = contentColor,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium,
            color = contentColor
        )
    }
}

@Composable
fun CarDescriptionCard(description: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(basicMargin),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Text(
            text = description,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSecondaryContainer,
            modifier = Modifier.padding(basicMargin)
        )
    }
}