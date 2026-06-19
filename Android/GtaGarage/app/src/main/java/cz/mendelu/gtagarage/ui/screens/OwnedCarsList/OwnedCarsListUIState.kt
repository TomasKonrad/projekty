package cz.mendelu.gtagarage.ui.screens.OwnedCarsList

import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.Garage

data class OwnedCarsListUIState(
    val garageId: String = "",
    val ownedCars: List<Car>? = null,
    val isLoading: Boolean = true,
    val noInternetError: Int? = null,
    val garage: Garage? = null,
    val showGarageFullSnackbar: Boolean = false,
    val showDeleteGarageDialog: Boolean = false,
    val garageDeleted: Boolean = false,
    val showErrorSnackbar: Boolean = false
)
