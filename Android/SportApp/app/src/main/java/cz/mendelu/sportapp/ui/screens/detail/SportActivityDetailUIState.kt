package cz.mendelu.sportapp.ui.screens.detail

import cz.mendelu.sportapp.database.Sport

data class SportActivityDetailUIState(
    val sport: Sport? = null,
    val showDeleteDialog: Boolean = false,
    val sportActivityDeleted: Boolean = false,
    var loading: Boolean = true
)
