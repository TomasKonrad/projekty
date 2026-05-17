package cz.mendelu.sportapp.ui.screens.detail

import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color.Companion
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

@Composable
fun SportActivityDetailScreen(
    navigationRouter: INavigationRouter,
    viewModel: SportActvityDetailViewModel = hiltViewModel(),
    actions: SportActivityDetailScreenActions
){
    val state = viewModel.detailSportActivityUIState.collectAsStateWithLifecycle()
    val sportId = state.value.sport?.id

    if (state.value.showDeleteDialog) {
        DeleteConfirmDialog(
            onConfirm = actions::onDeleteConfirm,
            onDismiss = actions::onDeleteDismiss
        )
    }

    LaunchedEffect(state.value.sportActivityDeleted) {
        if (state.value.sportActivityDeleted) {
            navigationRouter.returnBack()
        }
    }

    BaseScreen(
        topBarText = stringResource(R.string.detail),
        showLoading = state.value.loading,
        onBackClick = {
            navigationRouter.returnBack()
        },
        actions = {
            IconButton(
                onClick = {
                    actions.onDeleteClick()
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
                onClick = {
                    sportId?.let {
                        navigationRouter.navigateToAddEditSportActivity(it)
                    }
                }
            ) {
                Icon(
                    imageVector = Icons.Default.Edit,
                    contentDescription = null
                )
            }
        },
        content = { paddingValues ->
            SportActivityDetailScreenContent(
                paddingValues = paddingValues,
                state = state.value,
            )

        }
    )
}


@Composable
fun SportActivityDetailScreenContent(
    paddingValues: PaddingValues,
    state: SportActivityDetailUIState
) {
    Column(
        modifier = Modifier
            .padding(paddingValues)
            .padding(horizontal = basicMargin)
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(halfMargin)
    ) {
        state.sport?.let { sport ->
            Text(
                text = sport.title,
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(bottom = basicMargin, top = basicMargin)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(IntrinsicSize.Min),
                horizontalArrangement = Arrangement.spacedBy(basicMargin),

            ) {
                InfoCard(
                    label = stringResource(R.string.sport_place),
                    value = sport.place,
                    icon = Icons.Default.Place,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )

                InfoCard(
                    label = stringResource(R.string.sport_type_of_activity),
                    value = sport.typeOfActivity.type,
                    icon = sport.typeOfActivity.icon,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(IntrinsicSize.Min),
                horizontalArrangement = Arrangement.spacedBy(basicMargin)
            ) {
                InfoCard(
                    label = stringResource(R.string.sport_in_duration_minutes),
                    value = "${sport.durationInMinutes} min",
                    icon = Icons.Default.Timer,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )

                InfoCard(
                    label = stringResource(R.string.sport_burned_calories),
                    value = "${sport.burnedCalories} kcal",
                    icon = Icons.Default.LocalFireDepartment,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )
            }

            if (!sport.description.isNullOrEmpty()) {
                Text(
                    text = stringResource(R.string.sport_description),
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(top = basicMargin, bottom = halfMargin)
                )
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = sport.description!!,
                        modifier = Modifier.padding(basicMargin),
                        style = MaterialTheme.typography.bodyLarge,
                        color = Color.Black,
                    )
                }
                Spacer(modifier = Modifier.height(80.dp))
            }
        }
    }
}


@Composable
fun InfoCard(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    icon: ImageVector,
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
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(halfMargin))
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun DeleteConfirmDialog(
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = stringResource(R.string.delete_dialog_title)
            )
        },
        text = {
            Text(text = stringResource(R.string.delete_dialog_message))
        },
        confirmButton = {
            Button(
                onClick = onConfirm
            ) {
                Text(
                    stringResource(R.string.delete_confirm)
                )
            }
        },
        dismissButton = {
            OutlinedButton(
                onClick = onDismiss
            ) {
                Text(
                    stringResource(R.string.cancel)
                )
            }
        }
    )
}