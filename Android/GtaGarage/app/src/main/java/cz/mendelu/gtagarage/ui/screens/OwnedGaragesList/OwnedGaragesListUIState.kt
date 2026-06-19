package cz.mendelu.gtagarage.ui.screens.OwnedGaragesList

import cz.mendelu.gtagarage.database.model.OwnedGarage

data class OwnedGaragesListUIState(
    val ownedGarages: List<OwnedGarage>? = null,
    val isLoading: Boolean = true,

    val noInternetError: Int? = null,
    val isOfflineFirstLaunch: Boolean = false,
    val appVersion: String = ""
)
