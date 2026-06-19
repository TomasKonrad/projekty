package cz.mendelu.gtagarage.ui.screens.StatisticsScreen

import cz.mendelu.gtagarage.database.model.BrandCount
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.VehicleClassCount

data class StatisticsUIState(
    val isLoading: Boolean = true,
    val isEmpty: Boolean = false,

    val totalCarsCount: Int = 0,
    val totalGaragesCount: Int = 0,
    val totalCarsValue: Double = 0.0,
    val totalGaragesValue: Double = 0.0,

    val mostExpensiveCar: Car? = null,
    val fastestCar: Car? = null,

    val carCountByClass: List<VehicleClassCount> = emptyList(),
    val carCountByBrand: List<BrandCount> = emptyList(),

    val lastSyncTimestamp: Long? = null
)