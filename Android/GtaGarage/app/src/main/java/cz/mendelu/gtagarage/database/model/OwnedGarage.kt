package cz.mendelu.gtagarage.database.model

data class OwnedGarage(
    val garageId: String = "",
    val garageName: String = "",
    val garageLocationName: String = "",
    val garageCapacity: Int = 0,
    val garagePurchasePrice: Double = 0.0
)