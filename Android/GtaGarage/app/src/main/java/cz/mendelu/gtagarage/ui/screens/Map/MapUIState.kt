package cz.mendelu.gtagarage.ui.screens.Map

import cz.mendelu.gtagarage.database.model.Garage

data class MapUIState(
    val isLoading: Boolean = true,
    val garages: List<Garage> = emptyList(),
    val selectedGarage: Garage? = null,

    val isOfflineFirstLaunch: Boolean = false
)
