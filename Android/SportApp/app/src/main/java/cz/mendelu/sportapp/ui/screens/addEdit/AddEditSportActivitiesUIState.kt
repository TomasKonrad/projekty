package cz.mendelu.sportapp.ui.screens.addEdit

import cz.mendelu.sportapp.database.Sport
import cz.mendelu.sportapp.database.SportActivity

data class AddEditSportActivitiesUIState(
    var sport: Sport = Sport("", "", 0, 0.0, SportActivity.RUN, ""),
    var sportActivitySaved: Boolean = false,

    var sportActivityTitleError: Int? = null,
    var sportActivityPlaceError: Int? = null,

    var sportActivityDurationInMinutes: String = "",
    var sportActivityDurationInMinutesError: Int? = null,

    var sportActivityBurnedCalories: String = "",
    var sportActivityBurnedCaloriesError: Int? = null,

    var loading: Boolean = true
)