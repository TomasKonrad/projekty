package cz.mendelu.gtagarage.ui.screens.AddEditCar

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuAnchorType.Companion.PrimaryNotEditable
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.OwnedGarage
import cz.mendelu.gtagarage.database.model.VehicleClass
import cz.mendelu.gtagarage.navigation.INavigationRouter
import cz.mendelu.gtagarage.ui.screens.elements.AppDropdown
import cz.mendelu.gtagarage.ui.screens.elements.BaseScreen
import cz.mendelu.gtagarage.ui.screens.elements.LoadingScreen
import cz.mendelu.gtagarage.ui.theme.Dimens.basicMargin
import cz.mendelu.gtagarage.ui.theme.Dimens.halfMargin
import java.io.File

@Composable
fun AddEditCarScreen(
    navigationRouter: INavigationRouter,
    viewModel: AddEditCarViewModel = hiltViewModel()
) {
    val state = viewModel.addEditCarUiState.collectAsStateWithLifecycle()

    LaunchedEffect(state.value.isSaved) {
        if (state.value.isSaved) {
            navigationRouter.returnBack()
        }
    }

    val addEditTopBarText = if (state.value.isEditMode) {
        R.string.edit_car
    } else {
        R.string.add_car
    }

    BaseScreen(
        topBarText = stringResource(addEditTopBarText),
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
                AddEditCarScreenContent(
                    paddingValues = paddingValues,
                    state = state.value,
                    actions = viewModel
                )
            }
        }
    )
}

@Composable
fun AddEditCarScreenContent(
    paddingValues: PaddingValues,
    state: AddEditCarUIState,
    actions: AddEditCarScreenActions
) {
    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri ->
        actions.onImageSelected(uri)
    }

    val selectedGarage = state.garages.find { garage ->
        garage.garageId == state.car.garageId
    }
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = basicMargin, vertical = basicMargin),
        verticalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.car.name,
            onValueChange = { name->
                actions.onNameChanged(name)
            },
            label = { Text(stringResource(R.string.car_name)) },
            isError = state.nameError != null,
            supportingText = if (state.nameError != null) {
                { Text(stringResource(state.nameError)) }
            } else null,
            singleLine = true
        )

        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.car.brand,
            onValueChange = { brand->
                actions.onBrandChanged(brand)
            },
            label = { Text(stringResource(R.string.car_brand)) },
            isError = state.brandError != null,
            supportingText = if (state.brandError != null) {
                { Text(stringResource(state.brandError)) }
            } else null,
            singleLine = true
        )

        AppDropdown(
            label = stringResource(R.string.vehicle_type),
            selectedValue = state.car.vehicleClass.type,
            items = VehicleClass.entries,
            itemLabel = { it.type },
            onSelected = { actions.onVehicleClassChanged(it) }
        )

        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.maxSpeedInput,
            onValueChange = { speed->
                actions.onMaxSpeedChanged(speed)
            },
            label = { Text(stringResource(R.string.car_max_speed)) },
            isError = state.maxSpeedError != null,
            supportingText = if (state.maxSpeedError != null) {
                { Text(stringResource(state.maxSpeedError)) }
            } else null,
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Number
            ),
            singleLine = true
        )

        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.purchasePriceInput,
            onValueChange = { price->
                actions.onPurchasePriceChanged(price)
            },
            label = { Text(stringResource(R.string.car_purchasePrice)) },
            isError = state.purchasePriceError != null,
            supportingText = if (state.purchasePriceError != null) {
                { Text(stringResource(state.purchasePriceError)) }
            } else null,
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Decimal
            ),
            singleLine = true
        )

        OutlinedTextField(
            modifier = Modifier.fillMaxWidth(),
            value = state.car.description,
            onValueChange = { description ->
                actions.onDescriptionChanged(description)
            },
            label = { Text(stringResource(R.string.description)) },
            maxLines = 6
        )

        if (state.isEditMode) {
            AppDropdown(
                label = stringResource(R.string.garages),
                selectedValue = selectedGarage?.garageName ?: "",
                items = state.garages,
                itemLabel = { it.garageName },
                onSelected = { actions.onGarageSelected(it.garageId) },
                isError = state.garageCapacityError != null,
                supportingText = state.garageCapacityError?.let { stringResource(it) }
            )
        }

        CarImageSection(
            selectedImageUri = state.selectedImageUri,
            existingImagePath = state.existingImagePath,
            onSelectImageClick = {
                imagePickerLauncher.launch("image/*")
            }
        )

        Button(
            onClick = {
                actions.saveCar()
            },
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding(),
            enabled = !state.isLoading
        ) {
            Icon(
                imageVector = Icons.Default.Save,
                contentDescription = null,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(halfMargin))
            Text(stringResource(
                if (state.isEditMode) {
                    R.string.save_changes
                } else {
                    R.string.save_car
                }
            ))
        }
    }
}

@Composable
fun CarImageSection(
    selectedImageUri: Uri?,
    existingImagePath: String,
    onSelectImageClick: () -> Unit
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(basicMargin)
    ) {
        when {
            selectedImageUri != null -> {
                AsyncImage(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(220.dp),
                    model = selectedImageUri,
                    contentDescription = null,
                    contentScale = ContentScale.Crop
                )
            }

            existingImagePath.isNotEmpty() -> {
                AsyncImage(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(220.dp),
                    model = File(existingImagePath),
                    contentDescription = null,
                    contentScale = ContentScale.Crop
                )
            }
        }

        OutlinedButton(
            modifier = Modifier.fillMaxWidth(),
            onClick = onSelectImageClick
        ) {
            Icon(
                imageVector = Icons.Default.Image,
                contentDescription = null,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(halfMargin))
            Text(
                text = if (selectedImageUri != null || existingImagePath.isNotEmpty()) {
                    stringResource(R.string.change_image)
                } else {
                    stringResource(R.string.add_image)
                }
            )
        }
    }
}