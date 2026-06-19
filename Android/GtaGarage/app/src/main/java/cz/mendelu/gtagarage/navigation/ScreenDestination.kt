package cz.mendelu.gtagarage.navigation

import kotlinx.serialization.Serializable

interface ScreenDestination {
    @Serializable
    data object OwnedGaragesList : ScreenDestination

    @Serializable
    data object GarageList : ScreenDestination

    @Serializable
    data class GarageDetail(val garageId: String) : ScreenDestination

    @Serializable
    data class CarsInGarage(val garageId: String) : ScreenDestination
    @Serializable
    data object Map : ScreenDestination

    @Serializable
    data object Statistics : ScreenDestination

    @Serializable
    data class AddEditCar(val carId: String? = null, val garageId: String) : ScreenDestination

    @Serializable
    data class CarDetail(val carId: String) : ScreenDestination
}