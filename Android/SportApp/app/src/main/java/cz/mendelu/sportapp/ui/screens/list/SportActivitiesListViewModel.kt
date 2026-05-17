package cz.mendelu.sportapp.ui.screens.list

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.sportapp.database.ISportRepository
import cz.mendelu.sportapp.ui.theme.activityColors
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class SportActivitiesListViewModel @Inject constructor(private val repository: ISportRepository) : ViewModel() {
    private val _sportActivitiesListUIState: MutableStateFlow<SportActivitiesListUIState> =
        MutableStateFlow(SportActivitiesListUIState())
    val sportActivitiesListUIState = _sportActivitiesListUIState.asStateFlow()

    init {
        loadSportActivities()
    }

    private fun loadSportActivities(){
        viewModelScope.launch {
            repository.getAll().collect { sports ->
                _sportActivitiesListUIState.value = _sportActivitiesListUIState.value.copy(
                    sports = sports.map{ sport ->
                        SportActivityWithColor(
                           sport = sport,
                           color = activityColors.random()
                        )
                    }
                )
            }
        }
    }
}