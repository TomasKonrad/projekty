package cz.mendelu.gtagarage.ui.screens.OwnedCarsList

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.ICarRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import cz.mendelu.gtagarage.navigation.ScreenDestination
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class OwnedCarsListViewModel @Inject constructor(
    private val repository: ICarRepository,
    private val garageRepository: IGarageRepository,
    private val authRepository: IAuthRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {
    private val garageId: String =
        savedStateHandle.toRoute<ScreenDestination.CarsInGarage>().garageId
    private val _ownedCarsListUIState = MutableStateFlow(
        OwnedCarsListUIState(
            garageId = garageId
        )
    )
    val ownedCarsListUIState = _ownedCarsListUIState.asStateFlow()

    init {
        loadOwnedCars()
        loadGarage()
    }

    private fun loadOwnedCars() {
        viewModelScope.launch {
            val userId = authRepository.getOrCreateUserId()

            launch { repository.syncCars(userId, garageId) }

            repository.getCarsInGarage(userId, garageId).collect { ownedCars ->
                _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
                    ownedCars = ownedCars,
                    isLoading = false
                )
            }
        }
    }

    private fun loadGarage() {
        viewModelScope.launch {
            launch { garageRepository.syncGarages() }

            garageRepository.getGarageDetail(garageId).collect { garage ->
                _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
                    garage = garage
                )
            }
        }
    }

    fun isGarageFull(): Boolean {
        val garage = _ownedCarsListUIState.value.garage ?: return false
        val carsCount = _ownedCarsListUIState.value.ownedCars?.size ?: 0
        return carsCount >= garage.capacity
    }

    fun onGarageFullClick() {
        _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
            showGarageFullSnackbar = true
        )
    }

    fun clearGarageFullSnackbar() {
        _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
            showGarageFullSnackbar = false
        )
    }

    fun onDeleteGarageClick() {
        _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
            showDeleteGarageDialog = true
        )
    }

    fun onDeleteGarageDismiss() {
        _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
            showDeleteGarageDialog = false
        )
    }

    fun onDeleteGarageConfirm() {
        viewModelScope.launch {
            try {
                val userId = authRepository.getOrCreateUserId()
                repository.deleteCarsByGarageId(userId, garageId)
                garageRepository.deleteOwnedGarage(userId, garageId)

                _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
                    showDeleteGarageDialog = false,
                    garageDeleted = true
                )
            } catch (e: Exception) {
                _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
                    showDeleteGarageDialog = false,
                    showErrorSnackbar = true
                )
            }
        }
    }

    fun clearError() {
        _ownedCarsListUIState.value = _ownedCarsListUIState.value.copy(
            showErrorSnackbar = false
        )
    }
}