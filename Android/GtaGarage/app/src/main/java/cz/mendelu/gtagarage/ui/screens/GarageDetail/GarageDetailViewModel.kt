package cz.mendelu.gtagarage.ui.screens.GarageDetail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import cz.mendelu.gtagarage.navigation.ScreenDestination
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class GarageDetailViewModel @Inject constructor(
    private val repository: IGarageRepository,
    private val authRepository: IAuthRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {
    private val _garageDetailUIState: MutableStateFlow<GarageDetailUIState> =
        MutableStateFlow(GarageDetailUIState())
    val garageDetailUIState = _garageDetailUIState.asStateFlow()
    private val garageId: String = savedStateHandle.toRoute<ScreenDestination.GarageDetail>().garageId

    private var userId: String = ""

    init{
        viewModelScope.launch {
            userId = authRepository.getOrCreateUserId()
            loadGarage()
            checkIfOwned()
        }
    }

    private fun loadGarage(){
        viewModelScope.launch {
            repository.getGarageDetail(garageId).collect { garage ->
                _garageDetailUIState.value = _garageDetailUIState.value.copy(
                    garage = garage,
                    isLoading = false
                )
            }
        }
    }

    private fun checkIfOwned() {
        viewModelScope.launch {
            repository.getOwnedGarages(userId).collect { ownedGarages ->
                _garageDetailUIState.value = _garageDetailUIState.value.copy(
                    isAlreadyOwned = ownedGarages.any { it.garageId == garageId }
                )
            }
        }
    }

    fun addGarageToOwned(garage: Garage) {
        viewModelScope.launch {
            _garageDetailUIState.value = _garageDetailUIState.value.copy(
                isLoading = true
            )

            try {
                val userId = authRepository.getOrCreateUserId()
                repository.addGarageToOwned(userId = userId, garage = garage)
                _garageDetailUIState.value = _garageDetailUIState.value.copy(
                    isLoading = false,
                    garageSaved = true
                )
            } catch (e: Exception) {
                _garageDetailUIState.value = _garageDetailUIState.value.copy(
                    isLoading = false,
                    showErrorSnackbar = true
                )
            }
        }
    }

    fun clearError() {
        _garageDetailUIState.value = _garageDetailUIState.value.copy(
            showErrorSnackbar = false
        )
    }
}
