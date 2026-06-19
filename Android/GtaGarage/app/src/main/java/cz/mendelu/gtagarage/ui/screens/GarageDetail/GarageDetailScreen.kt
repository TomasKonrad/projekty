package cz.mendelu.gtagarage.ui.screens.GarageDetail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.DetailHeaderImage
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import java.text.NumberFormat
import java.util.Locale

@Composable
fun GarageDetailScreen(
    navigationRouter: INavigationRouter,
    viewModel: GarageDetailViewModel = hiltViewModel(),
){
    val state = viewModel.garageDetailUIState.collectAsStateWithLifecycle()

    if(state.value.garageSaved){
        LaunchedEffect(state.value) {
            navigationRouter.returnBack()
        }
    }

    BaseScreen(
        topBarText = stringResource(R.string.garage_detail),
        onBackClick = {
            navigationRouter.returnBack()
        },
        snackbarMessage = if (state.value.showErrorSnackbar) {
            stringResource(R.string.error_no_internet)
        } else null,
        onSnackbarDismiss = { viewModel.clearError() },
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                GarageDetailScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    onAddGarageClick = { garage ->
                        viewModel.addGarageToOwned(garage)
                    }
                )
            }
        }
    )
}

@Composable
fun GarageDetailScreenContent(
    paddingValues: PaddingValues,
    state: GarageDetailUIState,
    onAddGarageClick: (Garage) -> Unit
) {
    val garage = state.garage ?: return

    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = basicMargin)
                .padding(top = basicMargin, bottom = 80.dp),
            verticalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            DetailHeaderImage(imagePath = garage.imagePath)

            GarageNameSection(name = garage.name, locationName = garage.locationName)

            GarageInfoGrid(
                capacity = garage.capacity,
                purchasePrice = garage.purchasePrice
            )

            if (garage.description.isNotEmpty()) {
                GarageDescriptionCard(description = garage.description)
            }
        }

        Button(
            onClick = { onAddGarageClick(garage) },
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .align(Alignment.BottomCenter)
                .padding(horizontal = basicMargin, vertical = basicMargin),
            enabled = !state.isAlreadyOwned
        ) {
            Text(
                stringResource(
                    if (state.isAlreadyOwned) R.string.garage_already_owned
                    else R.string.add_to_owned
                )
            )
        }
    }
}

@Composable
fun GarageNameSection(
    name: String,
    locationName: String
) {
    Text(
        text = name,
        style = MaterialTheme.typography.titleLarge
    )
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
            text = locationName,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun GarageInfoGrid(
    capacity: Int,
    purchasePrice: Double
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        GarageInfoCard(
            modifier = Modifier.weight(1f),
            icon = Icons.Default.DirectionsCar,
            label = stringResource(R.string.capacity),
            value = stringResource(R.string.capacity_value, capacity)
        )
        GarageInfoCard(
            modifier = Modifier.weight(1f),
            icon = Icons.Default.AttachMoney,
            label = stringResource(R.string.purchase_price),
            value = NumberFormat.getCurrencyInstance(Locale.US).format(purchasePrice)
        )
    }
}

@Composable
fun GarageInfoCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    label: String,
    value: String
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(basicMargin),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(basicMargin),
            verticalArrangement = Arrangement.spacedBy(halfMargin)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(halfMargin)
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSecondaryContainer,
                    modifier = Modifier.size(20.dp)
                )
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
            }
            Text(
                text = value,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
        }
    }
}

@Composable
private fun GarageDescriptionCard(
    description: String
) {
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