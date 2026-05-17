package cz.mendelu.sportapp.ui.screens.statistics

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.sportapp.database.ISportRepository
import cz.mendelu.sportapp.database.SportActivity
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class SportActivitiesStatisticsViewModel @Inject constructor(
    private val repository: ISportRepository
) : ViewModel() {

    private val _sportActivitiesStatisticsUIState = MutableStateFlow(SportActivitiesStatisticsUIState())
    val sportActivitiesStatisticsUIState = _sportActivitiesStatisticsUIState.asStateFlow()

    init {
        loadStatistics()
    }

    private fun loadStatistics() {
        viewModelScope.launch {
            _sportActivitiesStatisticsUIState.value = _sportActivitiesStatisticsUIState.value.copy(
                count = repository.getCountOfActivities(),
                totalMinutes = repository.getAllMinutes() ?: 0,
                mostCommonActivity = repository.getMostCommonActivity()
                    ?.let { SportActivity.valueOf(it) },
                loading = false
            )
        }
    }
}