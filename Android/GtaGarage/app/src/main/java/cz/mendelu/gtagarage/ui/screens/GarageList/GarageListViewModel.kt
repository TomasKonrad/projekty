package cz.mendelu.gtagarage.ui.screens.GarageList

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.gtagarage.database.NetworkMonitor
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class GarageListViewModel @Inject constructor(
    private val repository: IGarageRepository,
    private val authRepository: IAuthRepository,
    private val networkMonitor: NetworkMonitor
) : ViewModel() {
    private val _garageListUIState: MutableStateFlow<GarageListUIState> =
        MutableStateFlow(GarageListUIState())
    val garageListUIState = _garageListUIState.asStateFlow()

    private var userId: String = ""

    init {
        viewModelScope.launch {
            userId = authRepository.getOrCreateUserId()
            networkMonitor.isOnline.collect { isOnline ->
                if (isOnline) {
                    if (userId.isEmpty()) {
                        userId = authRepository.getOrCreateUserId()
                    }
                    _garageListUIState.value = _garageListUIState.value.copy(
                        isOfflineFirstLaunch = false
                    )
                    loadGarages()
                    checkIfOwned()
                } else {
                    loadGaragesFromCache()
                    checkIfOwned()
                }
            }
        }
    }

    private fun loadGarages(){
        viewModelScope.launch {
            launch { repository.syncGarages() }

            repository.getAllGarages().collect { garages ->
                _garageListUIState.value = _garageListUIState.value.copy(
                    garages = garages,
                    isLoading = false
                )
            }
        }
    }

    private fun loadGaragesFromCache() {
        viewModelScope.launch {
            repository.getAllGarages().collect { garages ->
                _garageListUIState.value = _garageListUIState.value.copy(
                    garages = garages,
                    isLoading = false,
                    isOfflineFirstLaunch = garages.isEmpty()
                )
            }
        }
    }

    private fun checkIfOwned() {
        viewModelScope.launch {
            repository.getOwnedGarages(userId).collect { ownedGarages ->
                _garageListUIState.value = _garageListUIState.value.copy(
                    ownedGarageIds = ownedGarages.map { it.garageId }.toSet()
                )
            }
        }
    }

    fun addGarageToOwned(garage: Garage) {
        viewModelScope.launch {
            try {
                val userId = authRepository.getOrCreateUserId()
                repository.addGarageToOwned(userId = userId, garage = garage)
                _garageListUIState.value = _garageListUIState.value.copy(
                    garageSaved = true
                )
            } catch (e: Exception) {
                _garageListUIState.value = _garageListUIState.value.copy(
                    showErrorSnackbar = true
                )
            }
        }
    }

    fun clearError() {
        _garageListUIState.value = _garageListUIState.value.copy(
            showErrorSnackbar = false
        )
    }
}