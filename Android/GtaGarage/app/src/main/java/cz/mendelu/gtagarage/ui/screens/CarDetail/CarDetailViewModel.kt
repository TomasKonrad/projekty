package cz.mendelu.gtagarage.ui.screens.CarDetail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.ICarRepository
import cz.mendelu.gtagarage.navigation.ScreenDestination
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
@HiltViewModel
class CarDetailViewModel @Inject constructor(
    private val repository: ICarRepository,
    private val authRepository: IAuthRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel(), CarDetailScreenActions {
    private val carId: String = savedStateHandle.toRoute<ScreenDestination.CarDetail>().carId
    private var userId: String = ""

    private val _carDetailUIState: MutableStateFlow<CarDetailUIState> =
        MutableStateFlow(CarDetailUIState())

    val carDetailUIState = _carDetailUIState.asStateFlow()

    init {
        loadCar()
    }

    private fun loadCar(){
        viewModelScope.launch {
            userId = authRepository.getOrCreateUserId()
            repository.getCarDetail(userId, carId).collect { car ->
                _carDetailUIState.value = _carDetailUIState.value.copy(
                    car = car,
                    isLoading = false
                )
            }
        }
    }

    override fun onDeleteClick() {
        _carDetailUIState.value = _carDetailUIState.value.copy(
            showDeleteDialog = true
        )
    }

    override fun onDeleteConfirm() {
        val carToDelete = _carDetailUIState.value.car ?: return
        viewModelScope.launch {
            try {
                repository.deleteCar(userId, carToDelete)
                _carDetailUIState.value = _carDetailUIState.value.copy(
                    carDeleted = true,
                    showDeleteDialog = false
                )
            } catch (e: Exception) {
                _carDetailUIState.value = _carDetailUIState.value.copy(
                    showDeleteDialog = false,
                    showErrorSnackbar = true
                )
            }
        }
    }

    override fun onDeleteDismiss() {
        _carDetailUIState.value = _carDetailUIState.value.copy(
            showDeleteDialog = false
        )
    }

    fun clearError() {
        _carDetailUIState.value = _carDetailUIState.value.copy(
            showErrorSnackbar = false
        )
    }
}