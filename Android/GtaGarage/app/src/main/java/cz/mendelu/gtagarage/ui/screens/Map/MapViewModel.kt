package cz.mendelu.gtagarage.ui.screens.Map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.gtagarage.database.NetworkMonitor
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class MapViewModel @Inject constructor(
    private val repository: IGarageRepository,
    private val networkMonitor: NetworkMonitor
) : ViewModel(){
    private val _mapUIState: MutableStateFlow<MapUIState> =
        MutableStateFlow(MapUIState())
    val mapUIState = _mapUIState.asStateFlow()

    init {
        viewModelScope.launch {
            networkMonitor.isOnline.collect { isOnline ->
                if (isOnline) {
                    _mapUIState.value = _mapUIState.value.copy(
                        isOfflineFirstLaunch = false
                    )
                    loadGarages()
                } else {
                    loadGaragesFromCache()
                }
            }
        }
    }

    private fun loadGarages(){
        viewModelScope.launch {
            _mapUIState.value = _mapUIState.value.copy(
                isLoading = true
            )

            launch { repository.syncGarages() }

            repository.getAllGarages().collect { garages ->
                _mapUIState.value = _mapUIState.value.copy(
                    garages = garages,
                    isLoading = false,
                    isOfflineFirstLaunch = garages.isEmpty()
                )
            }
        }
    }

    private fun loadGaragesFromCache() {
        viewModelScope.launch {
            repository.getAllGarages().collect { garages ->
                _mapUIState.value = _mapUIState.value.copy(
                    garages = garages,
                    isLoading = false,
                    isOfflineFirstLaunch = garages.isEmpty()
                )
            }
        }
    }

    fun garageSheetInfo(garageId: String){
        viewModelScope.launch {
            val garage = repository.getGarageMarkerDetail(garageId)
            _mapUIState.value = _mapUIState.value.copy(
                selectedGarage = garage,
                isLoading = false
            )
        }
    }

    fun clearSelectedGarage() {
        _mapUIState.value = _mapUIState.value.copy(
            selectedGarage = null
        )
    }
}