package cz.mendelu.sportapp.ui.screens.addEdit

import cz.mendelu.sportapp.database.SportActivity

interface AddEditSportsActivitiesScreenActions {
    fun onTitleChanged(title: String)
    fun onPlaceChanged(place: String)
    fun onDurationInMinutesChanged(duration: String)
    fun onBurnedCaloriesChanged(calories: String)
    fun onTypeOfActivityChanged(typeOfActivity: SportActivity)
    fun onDescriptionChanged(description: String)
    fun saveSportActivity()
}