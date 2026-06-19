package cz.mendelu.gtagarage.ui.screens.CarDetail

import cz.mendelu.gtagarage.database.model.Car

data class CarDetailUIState(
    val car: Car? = null,
    val showDeleteDialog: Boolean = false,
    val carDeleted: Boolean = false,
    val isLoading: Boolean = true,

    val noInternetError: Int? = null,
    val showErrorSnackbar: Boolean = false
)
