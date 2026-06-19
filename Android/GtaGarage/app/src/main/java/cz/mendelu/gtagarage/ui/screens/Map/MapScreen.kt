@file:OptIn(ExperimentalTelephotoApi::class)

package cz.mendelu.gtagarage.ui.screens.Map

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavDestination
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.BottomNavigationMenu
import cz.mendelu.gtagarage.ui.screens.elements.DetailHeaderImage
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.screens.elements.Placeholder.PlaceholderScreenContent
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.largeMargin
import kotlinx.coroutines.launch
import me.saket.telephoto.ExperimentalTelephotoApi
import me.saket.telephoto.zoomable.ZoomSpec
import me.saket.telephoto.zoomable.ZoomableState
import me.saket.telephoto.zoomable.coil.ZoomableAsyncImage
import me.saket.telephoto.zoomable.rememberZoomableImageState
import me.saket.telephoto.zoomable.rememberZoomableState
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    navigationRouter: INavigationRouter,
    currentDestination: NavDestination?,
    viewModel: MapViewModel = hiltViewModel(),
){
    val state = viewModel.mapUIState.collectAsStateWithLifecycle()

    BaseScreen(
        bottomBar = {
            BottomNavigationMenu(
                currentDestination = currentDestination,
                onMapClick = { navigationRouter.navigateToMap() },
                onOwnedGaragesClick = { navigationRouter.navigateToOwnedGarageList() },
                onStatisticsClick = { navigationRouter.navigateToStatistics() }
            )
        },
        placeholderScreenContent = if (state.value.isOfflineFirstLaunch) {
            PlaceholderScreenContent(
                lottieAnimation = "Animations/no_internet_cat.json",
                text = R.string.no_internet_first_launch
            )
        } else null,
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                MapScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    onMarkerClick = { garage ->
                        viewModel.garageSheetInfo(garage.id)
                    },
                    onSheetDismiss = {
                        viewModel.clearSelectedGarage()
                    },
                    onSeeDetailsClick = { garage ->
                        navigationRouter.navigateToGarageDetail(garage.id)
                    }
                )
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreenContent(
    paddingValues: PaddingValues,
    state: MapUIState,
    onMarkerClick: (Garage) -> Unit,
    onSheetDismiss: () -> Unit,
    onSeeDetailsClick: (Garage) -> Unit
) {
    val zoomableState = rememberZoomableState(zoomSpec = ZoomSpec(maxZoomFactor = 6f))
    val imageState = rememberZoomableImageState(zoomableState)
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
    ){
        ZoomableAsyncImage(
            model = "file:///android_asset/gta_cela_mapa.png",
            state = imageState,
            modifier = Modifier.fillMaxSize(),
            contentDescription = "GTA Map",
            contentScale = ContentScale.Crop
        )

        if (!imageState.isImageDisplayed) {
            LoadingScreen()
        }

        state.garages.forEach { garage ->
            MapMarker(
                garage = garage,
                zoomableState = zoomableState,
                onClick = { onMarkerClick(garage) }
            )
        }
    }
    state.selectedGarage?.let { garage ->
        ModalBottomSheet(
            onDismissRequest = onSheetDismiss,
            sheetState = sheetState
        ) {
            GarageBottomSheetContent(
                garage = garage,
                onSeeDetailsClick = {
                    scope.launch {
                        sheetState.hide()
                        onSeeDetailsClick(garage)
                    }
                }
            )
        }
    }
}

@Composable
fun GarageBottomSheetContent(
    garage: Garage,
    onSeeDetailsClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = basicMargin)
            .padding(bottom = largeMargin),
        verticalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = garage.name,
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
                    text = garage.locationName,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        DetailHeaderImage(imagePath = garage.imagePath)

        Surface(
            shape = RoundedCornerShape(basicMargin),
            color = MaterialTheme.colorScheme.secondaryContainer
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = basicMargin, vertical = halfMargin),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(halfMargin)
            ) {
                Icon(
                    imageVector = Icons.Default.DirectionsCar,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSecondaryContainer,
                    modifier = Modifier.size(18.dp)
                )
                Text(
                    text = stringResource(R.string.capacity),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                )
                Text(
                    text = stringResource(R.string.capacity_value, garage.capacity),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
            }
        }

        Button(
            onClick = onSeeDetailsClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(stringResource(R.string.see_detail))
        }
    }
}
/*
@Composable
fun GarageBottomSheetContent(
    garage: Garage,
    onSeeDetailsClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(largeMargin)
    ) {
//        GarageSheetImage(
//            imageUrl = garage.imagePath
//        )
        DetailHeaderImage(
            imagePath = garage.imagePath
        )

        Spacer(modifier = Modifier.height(halfMargin))

        Text(
            text = garage.name,
            style = MaterialTheme.typography.headlineSmall
        )

        Spacer(modifier = Modifier.height(halfMargin))

        Text(
            text = garage.locationName,
            style = MaterialTheme.typography.bodyLarge
        )

        Spacer(modifier = Modifier.height(halfMargin))

        Text(
            text = "Kapacita garáže: ${garage.capacity} vozidel",
            style = MaterialTheme.typography.bodyLarge
        )

        Spacer(modifier = Modifier.height(basicMargin))

        Button(
            onClick = onSeeDetailsClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(stringResource(R.string.see_detail))
        }
    }
}

 */

@Composable
fun MapMarker(
    garage: Garage,
    zoomableState: ZoomableState,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier.offset {
            val transform = zoomableState.contentTransformation
            val bounds = zoomableState.transformedContentBounds

            if (transform.isSpecified && !bounds.isEmpty && bounds.width > 0) {
                val xPx = bounds.left + (bounds.width * garage.latitude)
                val yPx = bounds.top + (bounds.height * garage.longitude)

                IntOffset(xPx.roundToInt(), yPx.roundToInt())
            } else {
                IntOffset(-10000, -10000)
            }
        }
    ) {
        Icon(
            imageVector = Icons.Filled.LocationOn,
            contentDescription = garage.name,
            tint = Color(0xFF3B4828),
            modifier = Modifier
                .offset(x = (-16).dp, y = (-32).dp)
                .size(40.dp)
                .clickable(onClick = onClick)
        )
    }
}

//@Composable
//fun GarageSheetImage(
//    imageUrl: String?
//) {
//    AsyncImage(
//        model = imageUrl,
//        contentDescription = null,
//        contentScale = ContentScale.Crop,
//        modifier = Modifier
//            .fillMaxWidth()
//            .height(220.dp)
//
//    )
//}