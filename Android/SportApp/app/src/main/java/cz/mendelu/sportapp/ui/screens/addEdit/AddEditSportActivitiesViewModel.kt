package cz.mendelu.sportapp.ui.screens.addEdit

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.sportapp.R
import cz.mendelu.sportapp.database.ISportRepository
import cz.mendelu.sportapp.database.SportActivity
import cz.mendelu.sportapp.ui.screens.addEdit.AddEditSportsActivitiesScreenActions
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AddEditSportActivitiesViewModel @Inject constructor(private val repository: ISportRepository)
    : ViewModel(), AddEditSportsActivitiesScreenActions {
    private val _addEditSportActivitiesUIState: MutableStateFlow<AddEditSportActivitiesUIState> =
        MutableStateFlow(AddEditSportActivitiesUIState())

    val addEditSportActivitiesUIState = _addEditSportActivitiesUIState.asStateFlow()

    fun loadSportActivities(id: Long?){
        if (id != null){
            viewModelScope.launch {
                val sport = repository.getById(id)
                _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
                    sport = sport,
                    sportActivityDurationInMinutes = sport.durationInMinutes.toString(),
                    sportActivityBurnedCalories = sport.burnedCalories.toString(),
                    loading = false
                )
            }
        } else {
            _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
                loading = false
            )
        }
    }

    override fun onTitleChanged(title: String) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sport = _addEditSportActivitiesUIState.value.sport.copy(title = title)
        )
    }

    override fun onPlaceChanged(place: String) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sport = _addEditSportActivitiesUIState.value.sport.copy(place = place)
        )
    }

    override fun onDurationInMinutesChanged(duration: String) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sportActivityDurationInMinutes = duration,
            sportActivityDurationInMinutesError = null
        )
    }

    override fun onBurnedCaloriesChanged(calories: String) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sportActivityBurnedCalories = calories,
            sportActivityBurnedCaloriesError = null
        )
    }

    override fun onTypeOfActivityChanged(typeOfActivity: SportActivity) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sport = _addEditSportActivitiesUIState.value.sport.copy( typeOfActivity = typeOfActivity)
        )
    }

    override fun onDescriptionChanged(description: String) {
        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sport = _addEditSportActivitiesUIState.value.sport.copy(description= description)
        )
    }

    private fun validateSportActivity(): Boolean {
        val sport = _addEditSportActivitiesUIState.value.sport

        val titleError = if (sport.title.isEmpty()) R.string.invalid_value else null
        val placeError = if (sport.place.isEmpty()) R.string.invalid_value else null

        val durationInMinutes = _addEditSportActivitiesUIState.value.sportActivityDurationInMinutes.toIntOrNull()
        val burnedCalories = _addEditSportActivitiesUIState.value.sportActivityBurnedCalories.toDoubleOrNull()

        val durationInMinutesError = if (durationInMinutes == null) R.string.invalid_value else null
        val burnedCalorieError = if (burnedCalories == null) R.string.invalid_value else null

        _addEditSportActivitiesUIState.value = _addEditSportActivitiesUIState.value.copy(
            sportActivityTitleError = titleError,
            sportActivityPlaceError = placeError,
            sportActivityDurationInMinutesError = durationInMinutesError,
            sportActivityBurnedCaloriesError = burnedCalorieError
        )
        return listOf(titleError, placeError, durationInMinutesError, burnedCalorieError)
            .all { it == null }
    }

    override fun saveSportActivity() {
        if (!validateSportActivity()) return

        val duration = _addEditSportActivitiesUIState.value.sportActivityDurationInMinutes.toInt()
        val calories = _addEditSportActivitiesUIState.value.sportActivityBurnedCalories.toDouble()

        viewModelScope.launch {
            val saveSport = _addEditSportActivitiesUIState.value.sport.copy(
                durationInMinutes = duration,
                burnedCalories = calories
            )

            if (_addEditSportActivitiesUIState.value.sport.id != null){
                repository.update(saveSport)
            } else {
                repository.insert(saveSport)
            }

            _addEditSportActivitiesUIState.value = addEditSportActivitiesUIState.value.copy(
                sportActivitySaved = true
            )
        }
    }
}