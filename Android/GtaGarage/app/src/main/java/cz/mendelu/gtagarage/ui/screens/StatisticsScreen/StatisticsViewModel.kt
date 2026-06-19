package cz.mendelu.gtagarage.ui.screens.StatisticsScreen

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.gtagarage.database.datastore.AppDataStore
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.ICarRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

@HiltViewModel
class StatisticsViewModel @Inject constructor(
    private val carRepository: ICarRepository,
    private val garageRepository: IGarageRepository,
    private val authRepository: IAuthRepository,
    private val appDataStore: AppDataStore
) : ViewModel() {

    private val _statisticsUIState = MutableStateFlow(StatisticsUIState())
    val statisticsUIState = _statisticsUIState.asStateFlow()

    init {
        loadStatistics()
    }

    private fun loadStatistics() {
        viewModelScope.launch {
            val userId = authRepository.getOrCreateUserId()

            if (userId.isEmpty()) {
                _statisticsUIState.value = _statisticsUIState.value.copy(
                    isLoading = false,
                    isEmpty = true
                )
            } else {
                garageRepository.syncGarages()
                garageRepository.syncOwnedGarages(userId)
                carRepository.syncAllCars(userId)

                val carsCount = carRepository.getTotalCarsCount(userId)
                val garagesCount = garageRepository.getTotalGaragesCount(userId)
                val carsValue = carRepository.getTotalCarsValue(userId)
                val garagesValue = garageRepository.getTotalGaragesValue(userId)
                val expensiveCar = carRepository.getMostExpensiveCar(userId)
                val fastest = carRepository.getFastestCar(userId)
                val byClass = carRepository.getCarCountByClass(userId)
                val byBrand = carRepository.getCarCountByBrand(userId)
                val timestamp = appDataStore.lastSyncTimestamp.first()

                android.util.Log.d("StatisticsVM", "userId: $userId")
                android.util.Log.d("StatisticsVM", "carsCount: $carsCount")
                android.util.Log.d("StatisticsVM", "garagesCount: $garagesCount")

                _statisticsUIState.value = _statisticsUIState.value.copy(
                    isLoading = false,
                    isEmpty = carsCount == 0 && garagesCount == 0,
                    totalCarsCount = carsCount,
                    totalGaragesCount = garagesCount,
                    totalCarsValue = carsValue,
                    totalGaragesValue = garagesValue,
                    mostExpensiveCar = expensiveCar,
                    fastestCar = fastest,
                    carCountByClass = byClass,
                    carCountByBrand = byBrand,
                    lastSyncTimestamp = timestamp
                )
            }
        }
    }

    fun refresh() {
        _statisticsUIState.value = _statisticsUIState.value.copy(isLoading = true)
        loadStatistics()
    }
}