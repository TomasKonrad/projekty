package cz.mendelu.gtagarage.ui.screens.elements

import android.R.attr.start
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.NavDestination.Companion.hierarchy
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.navigation.BottomNavItem
import cz.mendelu.gtagarage.navigation.ScreenDestination
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.largeMargin

@Composable
fun BottomNavigationMenu(
    currentDestination: NavDestination?,
    onMapClick: () -> Unit,
    onOwnedGaragesClick: () -> Unit,
    onStatisticsClick: () -> Unit
) {
    val items = listOf(
        BottomNavItem(
            label = stringResource(R.string.map),
            icon = Icons.Default.LocationOn,
            onClick = onMapClick,
            isSelected = { destination ->
                destination?.hierarchy?.any { it.hasRoute<ScreenDestination.Map>() } == true
            }
        ),
        BottomNavItem(
            label = stringResource(R.string.owned_garages),
            icon = Icons.AutoMirrored.Filled.List,
            onClick = onOwnedGaragesClick,
            isSelected = { destination ->
                destination?.hierarchy?.any { it.hasRoute<ScreenDestination.OwnedGaragesList>() } == true
            }
        ),
        BottomNavItem(
            label = stringResource(R.string.statistics),
            icon = Icons.Default.BarChart,
            onClick = onStatisticsClick,
            isSelected = { destination ->
                destination?.hierarchy?.any { it.hasRoute<ScreenDestination.Statistics>() } == true
            }
        )
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(start = basicMargin, end = basicMargin, top = halfMargin, bottom = largeMargin),
        contentAlignment = Alignment.Center
    ){
        NavigationBar(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(28.dp)),
            tonalElevation = 0.dp,
        ) {
            items.forEach { item ->
                NavigationBarItem(
                    selected = item.isSelected(currentDestination),
                    onClick = item.onClick,
                    label = { Text(item.label) },
                    icon = {
                        Icon(
                            imageVector = item.icon,
                            contentDescription = item.label
                        )
                    }
                )
            }
        }
    }
}