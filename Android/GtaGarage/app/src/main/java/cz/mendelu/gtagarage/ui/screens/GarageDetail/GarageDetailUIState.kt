package cz.mendelu.gtagarage.ui.screens.GarageDetail

import cz.mendelu.gtagarage.database.model.Garage

data class GarageDetailUIState(
    val garage: Garage? = Garage("", "", "", 0.0,0.0,0,0.0,"",""),
    val isLoading: Boolean = true,
    val garageSaved: Boolean = false,

    val noInternetError: Int? = null,
    val showErrorSnackbar: Boolean = false,
    val isAlreadyOwned: Boolean = false
)
