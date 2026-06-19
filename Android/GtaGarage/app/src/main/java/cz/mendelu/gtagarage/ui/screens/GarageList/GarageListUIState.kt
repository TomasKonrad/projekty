package cz.mendelu.gtagarage.ui.screens.GarageList

import cz.mendelu.gtagarage.database.model.Garage

data class GarageListUIState(
    val garages: List<Garage>? = null,
    val isLoading: Boolean = true,
    val garageSaved: Boolean = false,

    val noInternetError: Int? = null,
    val showErrorSnackbar: Boolean = false,
    val ownedGarageIds: Set<String> = emptySet(),

    val isOfflineFirstLaunch: Boolean = false
)
