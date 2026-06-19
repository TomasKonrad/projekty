package cz.mendelu.gtagarage.ui.screens.StatisticsScreen

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Canvas
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavDestination
import com.patrykandpatrick.vico.compose.cartesian.CartesianChartHost
import com.patrykandpatrick.vico.compose.cartesian.axis.rememberBottom
import com.patrykandpatrick.vico.compose.cartesian.axis.rememberStart
import com.patrykandpatrick.vico.compose.cartesian.layer.rememberColumnCartesianLayer
import com.patrykandpatrick.vico.compose.cartesian.rememberCartesianChart
import com.patrykandpatrick.vico.compose.common.component.rememberLineComponent
import com.patrykandpatrick.vico.compose.common.fill
import com.patrykandpatrick.vico.core.cartesian.axis.HorizontalAxis
import com.patrykandpatrick.vico.core.cartesian.axis.VerticalAxis
import com.patrykandpatrick.vico.core.cartesian.data.CartesianChartModelProducer
import com.patrykandpatrick.vico.core.cartesian.data.columnSeries
import com.patrykandpatrick.vico.core.cartesian.layer.ColumnCartesianLayer
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.BrandCount
import cz.mendelu.gtagarage.database.model.VehicleClassCount
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.BottomNavigationMenu
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.screens.elements.Placeholder.PlaceholderScreenContent
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import java.text.DateFormat
import java.util.Date

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StatisticScreen(
    navigationRouter: INavigationRouter,
    currentDestination: NavDestination?,
    viewModel: StatisticsViewModel = hiltViewModel()
){
    val state = viewModel.statisticsUIState.collectAsStateWithLifecycle()

    val lifecycleOwner = LocalLifecycleOwner.current

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                viewModel.refresh()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    BaseScreen(
        topBarText = "Statistics",
        bottomBar = {
            BottomNavigationMenu(
                currentDestination = currentDestination,
                onMapClick = { navigationRouter.navigateToMap() },
                onOwnedGaragesClick = { navigationRouter.navigateToOwnedGarageList() },
                onStatisticsClick = { navigationRouter.navigateToStatistics() }
            )
        },
        placeholderScreenContent = if (state.value.isEmpty) {
            PlaceholderScreenContent(
                lottieAnimation = "Animations/no_data.json",
                text = R.string.no_statistics
            )
        } else null,
        content = { paddingValues ->
            if (state.value.isLoading) {
                LoadingScreen(paddingValues)
            } else {
                StatisticScreenContent(
                    paddingValues = paddingValues,
                    state = state.value
                )
            }
        }
    )
}

@Composable
fun StatisticScreenContent(
    paddingValues: PaddingValues,
    state: StatisticsUIState
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = basicMargin, vertical = basicMargin),
        verticalArrangement = Arrangement.spacedBy(basicMargin)
    ) {

        StatsSectionTitle(stringResource(R.string.stats_overview))
        StatsGrid(state = state)

        StatsSectionTitle(stringResource(R.string.stats_records))
        state.mostExpensiveCar?.let { car ->
            StatHighlightCard(
                icon = Icons.Default.AttachMoney,
                label = stringResource(R.string.stats_most_expensive),
                name = "${car.brand} ${car.name}",
                value = "$${car.purchasePrice}"
            )
        }
        state.fastestCar?.let { car ->
            StatHighlightCard(
                icon = Icons.Default.Speed,
                label = stringResource(R.string.stats_fastest),
                name = "${car.brand} ${car.name}",
                value = "${car.maxSpeed} mph"
            )
        }

        StatsSectionTitle(stringResource(R.string.stats_classes))
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(basicMargin),
            border = BorderStroke(0.5.dp, MaterialTheme.colorScheme.outlineVariant)
        ) {
            Column(modifier = Modifier.padding(basicMargin)) {
                Text(
                    text = stringResource(R.string.stats_class_count),
                    style = MaterialTheme.typography.bodyMedium
                )
                VehicleClassBarChart(data = state.carCountByClass)
            }
        }

        StatsSectionTitle(stringResource(R.string.stats_brands))
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(basicMargin),
            border = BorderStroke(0.5.dp, MaterialTheme.colorScheme.outlineVariant)
        ) {
            Column(modifier = Modifier.padding(basicMargin)) {
                Text(
                    text = stringResource(R.string.stats_brand_share),
                    style = MaterialTheme.typography.bodyMedium
                )
                Spacer(modifier = Modifier.height(halfMargin))
                BrandPieChart(data = state.carCountByBrand)
            }
        }
    }
}

@Composable
fun StatsSectionTitle(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.padding(vertical = halfMargin)
    )
}

@Composable
fun StatsGrid(state: StatisticsUIState) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        StatCard(
            modifier = Modifier.weight(1f),
            label = stringResource(R.string.stats_total_cars),
            value = state.totalCarsCount.toString()
        )
        StatCard(
            modifier = Modifier.weight(1f),
            label = stringResource(R.string.stats_total_garages),
            value = state.totalGaragesCount.toString()
        )
    }
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        StatCard(
            modifier = Modifier.weight(1f),
            label = stringResource(R.string.stats_cars_value),
            value = "$${String.format("%.1fM", state.totalCarsValue / 1_000_000)}"
        )
        StatCard(
            modifier = Modifier.weight(1f),
            label = stringResource(R.string.stats_garages_value),
            value = "$${String.format("%.1fM", state.totalGaragesValue / 1_000_000)}"
        )
    }
}

@Composable
fun StatCard(
    modifier: Modifier = Modifier,
    label: String,
    value: String
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(basicMargin),
        color = MaterialTheme.colorScheme.secondaryContainer
    ) {
        Column(
            modifier = Modifier.padding(basicMargin)
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            Text(
                text = value,
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onSecondaryContainer,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}

@Composable
fun StatHighlightCard(
    icon: ImageVector,
    label: String,
    name: String,
    value: String
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(basicMargin),
        border = BorderStroke(0.5.dp, MaterialTheme.colorScheme.outlineVariant)
    ) {
        Row(
            modifier = Modifier.padding(basicMargin),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(basicMargin)
        ) {
            Surface(
                shape = RoundedCornerShape(halfMargin),
                color = MaterialTheme.colorScheme.secondaryContainer
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSecondaryContainer,
                    modifier = Modifier.padding(halfMargin)
                )
            }
            Column {
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = name,
                    style = MaterialTheme.typography.bodyLarge

                )
                Text(
                    text = value,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun VehicleClassBarChart(data: List<VehicleClassCount>) {
    if (data.isEmpty()) return

    val modelProducer = remember { CartesianChartModelProducer() }

    LaunchedEffect(data) {
        modelProducer.runTransaction {
            columnSeries {
                series(data.map { it.count })
            }
        }
    }

    CartesianChartHost(
        chart = rememberCartesianChart(
            rememberColumnCartesianLayer(
                columnProvider = ColumnCartesianLayer.ColumnProvider.series(
                    rememberLineComponent(
                        fill = fill(MaterialTheme.colorScheme.primary),
                        thickness = 8.dp
                    )
                )
            ),
            startAxis = VerticalAxis.rememberStart(
                valueFormatter = { _, value, _ ->
                value.toInt().toString()
            },
            itemPlacer = VerticalAxis.ItemPlacer.step(
                step = { 1.0 }
            )
        ),
        bottomAxis = HorizontalAxis.rememberBottom(
            valueFormatter = { _, value, _ ->
                data.getOrNull(value.toInt())?.vehicleClass?.type ?: ""
            }
        )
    ),
    modelProducer = modelProducer,
    modifier = Modifier
        .fillMaxWidth()
        .height(220.dp)
    )
}

@Composable
fun BrandPieChart(data: List<BrandCount>) {
    if (data.isEmpty()) return

    val total = data.sumOf { it.count }.toFloat()
    val colors = listOf(
        MaterialTheme.colorScheme.primary,
        MaterialTheme.colorScheme.secondary,
        MaterialTheme.colorScheme.tertiary,
        MaterialTheme.colorScheme.surfaceVariant
    )

    val top3 = data.take(3)
    val othersCount = data.drop(3).sumOf { it.count }
    val chartData = if (othersCount > 0) top3 + BrandCount("Ostatní", othersCount) else top3

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        Canvas(
            modifier = Modifier
                .size(120.dp)
        ) {
            var startAngle = -90f
            chartData.forEachIndexed { index, item ->
                val sweepAngle = (item.count / total) * 360f
                drawArc(
                    color = colors[index % colors.size],
                    startAngle = startAngle,
                    sweepAngle = sweepAngle,
                    useCenter = true
                )
                startAngle += sweepAngle
            }
        }

        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            chartData.forEachIndexed { index, item ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(halfMargin)
                ) {
                    Box(
                        modifier = Modifier
                            .size(10.dp)
                            .background(
                                color = colors[index % colors.size],
                                shape = CircleShape
                            )
                    )
                    Text(
                        text = "${item.brand}: ${item.count}",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        }
    }
}