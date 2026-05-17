package cz.mendelu.sportapp.ui.screens.addEdit

import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import cz.mendelu.sportapp.R
import cz.mendelu.sportapp.database.SportActivity
import cz.mendelu.sportapp.navigation.INavigationRouter
import cz.mendelu.sportapp.ui.screens.addEdit.AddEditSportActivitiesUIState
import cz.mendelu.sportapp.ui.screens.addEdit.AddEditSportActivitiesViewModel
import cz.mendelu.sportapp.ui.screens.addEdit.AddEditSportsActivitiesScreenActions
import cz.mendelu.sportapp.ui.screens.elements.BaseScreen
import cz.mendelu.sportapp.ui.theme.Dimens.basicMargin

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditSportActivityScreen(
    navigationRouter: INavigationRouter,
    id: Long? = null,
    viewModel: AddEditSportActivitiesViewModel = hiltViewModel()
){
    val state = viewModel.addEditSportActivitiesUIState.collectAsStateWithLifecycle()

    LaunchedEffect(id) {
        viewModel.loadSportActivities(id)
    }

    if (state.value.sportActivitySaved){
        LaunchedEffect(state.value) {
            navigationRouter.returnBack()
        }
    }

    BaseScreen(
        topBarText = stringResource(R.string.add_sport),
        showLoading = state.value.loading,
        onBackClick = {
            navigationRouter.returnBack()
        },
        content = { paddingValues ->
            AddEditSportActivityContent(
                paddingValues = paddingValues,
                state = state.value,
                actions = viewModel
            )
        }
    )
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditSportActivityContent(
    paddingValues: PaddingValues,
    state: AddEditSportActivitiesUIState,
    actions: AddEditSportsActivitiesScreenActions
) {
    var expanded by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier.padding(
            top = paddingValues.calculateTopPadding(),
            start = basicMargin,
            end = basicMargin,
            bottom = basicMargin
        )
    ){
        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.sport.title,
            onValueChange = {
                actions.onTitleChanged(it)
            },
            singleLine = true,
            isError = state.sportActivityTitleError != null,
            supportingText = {
                if (state.sportActivityTitleError != null){
                    Text(text = stringResource(state.sportActivityTitleError!!))
                }
            },
            label = {
                Text(stringResource(R.string.sport_title))
            }
        )

        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.sport.place,
            onValueChange = {
                actions.onPlaceChanged(it)
            },
            singleLine = true,
            isError = state.sportActivityPlaceError != null,
            supportingText = {
                if (state.sportActivityPlaceError != null){
                    Text(text = stringResource(state.sportActivityPlaceError!!))
                }
            },
            label = {
                Text(stringResource(R.string.sport_place))
            }
        )


        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.sportActivityDurationInMinutes,
            onValueChange = { duration ->
                actions.onDurationInMinutesChanged(duration)
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), //přes klávesnici na počítači lze napsat cokoliv, na mobilu by se zobrazila pouze numerická klávesnice
            singleLine = true,
            isError = state.sportActivityDurationInMinutesError != null,
            supportingText = {
                if (state.sportActivityDurationInMinutesError != null){
                    Text(text = stringResource(state.sportActivityDurationInMinutesError!!))
                }
            },
            label = {
                Text(stringResource(R.string.sport_in_duration_minutes))
            }
        )


        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.sportActivityBurnedCalories,
            onValueChange = { calories ->
                actions.onBurnedCaloriesChanged(calories)
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            singleLine = true,
            isError = state.sportActivityBurnedCaloriesError != null,
            supportingText = {
                if (state.sportActivityBurnedCaloriesError != null){
                    Text(text = stringResource(state.sportActivityBurnedCaloriesError!!))
                }
            },
            label = {
                Text(stringResource(R.string.sport_burned_calories))
            }
        )

        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = it}
        ) {
            OutlinedTextField(
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor(MenuAnchorType.PrimaryNotEditable),
                readOnly = true,
                value = state.sport.typeOfActivity.type,
                onValueChange = {},
                label = { Text(stringResource(R.string.type_of_activity)) },
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                supportingText = {}
            )
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false}
            ) {
                SportActivity.entries.forEach { type ->
                    DropdownMenuItem(
                        text = {
                            Text(type.type)
                        },
                        onClick = {
                            actions.onTypeOfActivityChanged(type)
                            expanded = false
                        },
                        contentPadding = ExposedDropdownMenuDefaults.ItemContentPadding
                    )
                }
            }
        }

        state.sport.description?.let { descripion ->
            OutlinedTextField(
                modifier = Modifier.fillMaxWidth(),
                value = descripion,
                onValueChange = { newValue ->
                    actions.onDescriptionChanged(newValue)
                },
                maxLines = 6,
                label = {
                    Text(stringResource(R.string.sport_description))
                }
            )
        }
        Button(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    top = basicMargin
                ),
            onClick = {
                actions.saveSportActivity()
            }
        ) {
            Text(stringResource(R.string.save_sport_activity))
        }
    }
}


