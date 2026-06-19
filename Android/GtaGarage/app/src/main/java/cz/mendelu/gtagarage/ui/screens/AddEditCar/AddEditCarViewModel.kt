package cz.mendelu.gtagarage.ui.screens.AddEditCar

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import cz.mendelu.gtagarage.R
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.VehicleClass
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.ICarRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import cz.mendelu.gtagarage.navigation.ScreenDestination
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class AddEditCarViewModel @Inject constructor(
    private val carRepository: ICarRepository,
    private val garageRepository: IGarageRepository,
    private val authRepository: IAuthRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel(), AddEditCarScreenActions {
    private val garageId: String = savedStateHandle.toRoute<ScreenDestination.AddEditCar>().garageId
    private val carId: String? = savedStateHandle.toRoute<ScreenDestination.AddEditCar>().carId
    private var userId: String = ""

    private val _addEditCarUiState: MutableStateFlow<AddEditCarUIState> = MutableStateFlow(AddEditCarUIState(
        car = Car(garageId = garageId),
        isEditMode = carId != null
    ))

    val addEditCarUiState = _addEditCarUiState.asStateFlow()

    init {
        viewModelScope.launch {
            userId = authRepository.getOrCreateUserId()
            loadOwnedGarages()
            if (carId != null) loadCar(carId)
        }
    }

    private fun loadOwnedGarages(){
        viewModelScope.launch {
            garageRepository.getOwnedGarages(userId).collect { garages ->
                _addEditCarUiState.update { it.copy(garages = garages) }
            }
        }
    }

    private fun loadCar(carId: String) {
        viewModelScope.launch {
            carRepository.getCarDetail(userId, carId).collect { car ->
                car?.let {
                    _addEditCarUiState.update { state ->
                        state.copy(
                            car = car.copy(),
                            maxSpeedInput = car.maxSpeed.toString(),
                            purchasePriceInput = car.purchasePrice.toString(),
                            existingImagePath = car.imagePath,
                            isLoading = false
                        )
                    }
                }
            }
        }
    }

    override fun onNameChanged(name: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            car = _addEditCarUiState.value.car.copy(name = name),
            nameError = null
        )
    }

    override fun onBrandChanged(brand: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            car = _addEditCarUiState.value.car.copy(brand = brand),
            brandError = null
        )
    }

    override fun onVehicleClassChanged(vehicleClass: VehicleClass) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            car = _addEditCarUiState.value.car.copy(vehicleClass = vehicleClass)
        )
    }

    override fun onMaxSpeedChanged(maxSpeed: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            maxSpeedInput = maxSpeed,
            maxSpeedError = null
        )
    }

    override fun onPurchasePriceChanged(purchasePrice: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            purchasePriceInput = purchasePrice,
            purchasePriceError = null
        )
    }

    override fun onDescriptionChanged(description: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            car = _addEditCarUiState.value.car.copy(description = description)
        )
    }

    override fun onGarageSelected(garageId: String) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            car = _addEditCarUiState.value.car.copy(garageId = garageId)
        )
    }

    override fun onImageSelected(uri: Uri?) {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            selectedImageUri = uri,
        )
    }

    private suspend fun validate(): Boolean {
        val state = _addEditCarUiState.value
        val car = state.car

        val nameError = when {
            car.name.isBlank() -> R.string.empty_name
            car.name.length > 70 -> R.string.too_long_name
            else -> null
        }

        val brandError = when {
            car.brand.isBlank() -> R.string.empty_brand
            car.brand.length > 70 -> R.string.too_long_brand
            else -> null
        }

        val maxSpeed = state.maxSpeedInput.toIntOrNull()
        val maxSpeedError = when {
            state.maxSpeedInput.isBlank() -> R.string.empty_maxSpeed
            maxSpeed == null -> R.string.empty_maxSpeed
            maxSpeed < 0 -> R.string.negative_max_speed
            maxSpeed > 999 -> R.string.too_high_max_speed
            else -> null
        }

        val purchasePrice = state.purchasePriceInput.toDoubleOrNull()
        val purchasePriceError = when {
            state.purchasePriceInput.isBlank() -> R.string.purchase_price_empty
            purchasePrice == null -> R.string.purchase_price_empty
            purchasePrice < 0 -> R.string.negative_purchase_price
            purchasePrice > 14_999_999 -> R.string.too_high_purchase_price
            else -> null
        }

        val garage = garageRepository.getGarageDetail(car.garageId).first()
        val carCount = carRepository.getCarCountInGarage(userId, car.garageId)

        val garageCapacityError = when {
            carId != null && car.garageId == garageId -> null
            garage == null -> null
            carCount >= garage.capacity -> R.string.selected_garage_full
            else -> null
        }


        _addEditCarUiState.value = state.copy(
            nameError = nameError,
            brandError = brandError,
            maxSpeedError = maxSpeedError,
            purchasePriceError = purchasePriceError,
            garageCapacityError = garageCapacityError
        )

        return listOf(
            nameError,
            brandError,
            maxSpeedError,
            purchasePriceError,
            garageCapacityError
        ).all { it == null }
    }

    override fun saveCar() {
        _addEditCarUiState.value=_addEditCarUiState.value.copy(
            isLoading = true
        )

        viewModelScope.launch {
            if (!validate()) {
                _addEditCarUiState.value = _addEditCarUiState.value.copy(
                    isLoading = false
                )
            } else {
                try {
                    val carToSave = _addEditCarUiState.value.car.copy(
                        maxSpeed = _addEditCarUiState.value.maxSpeedInput.toInt(),
                        purchasePrice = _addEditCarUiState.value.purchasePriceInput.toDouble()
                    )

                    if (carId != null) {
                        carRepository.updateCar(
                            userId,
                            carToSave.copy(
                                id = carId,
                                imagePath = _addEditCarUiState.value.existingImagePath
                            ),
                            _addEditCarUiState.value.selectedImageUri
                        )
                    } else {
                        carRepository.addCar(userId, carToSave, _addEditCarUiState.value.selectedImageUri)
                    }

                    _addEditCarUiState.value = _addEditCarUiState.value.copy(
                        isLoading = false,
                        isSaved = true
                    )
                } catch (e: Exception) {
                    _addEditCarUiState.value = _addEditCarUiState.value.copy(
                        isLoading = false,
                        showErrorSnackbar = true
                    )
                }
            }
        }
    }

    fun clearError() {
        _addEditCarUiState.value = _addEditCarUiState.value.copy(
            showErrorSnackbar = false
        )
    }
}