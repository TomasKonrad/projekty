package cz.mendelu.sportapp.ui.screens.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import cz.mendelu.sportapp.database.ISportRepository
import cz.mendelu.sportapp.navigation.ScreenDestination.SportActivityDetail
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SportActvityDetailViewModel @Inject constructor(
    private val repository: ISportRepository,
    savedStateHandle: SavedStateHandle) : ViewModel(), SportActivityDetailScreenActions{
    private val destination = savedStateHandle.toRoute<SportActivityDetail>()
    private val sportActivityId = destination.id

    private val _detailSportActivityUIState: MutableStateFlow<SportActivityDetailUIState> =
        MutableStateFlow(SportActivityDetailUIState())

    val detailSportActivityUIState = _detailSportActivityUIState.asStateFlow()

    init {
        loadSportActivity()
    }

    private fun loadSportActivity(){
        viewModelScope.launch {
            repository.getByIdFlow(sportActivityId).collect { sportActivity ->
                if (sportActivity != null) {
                    _detailSportActivityUIState.value = _detailSportActivityUIState.value.copy(
                        sport = sportActivity,
                        loading = false
                    )
                } else {
                    _detailSportActivityUIState.value = _detailSportActivityUIState.value.copy(
                        sportActivityDeleted = true
                    )
                }
            }
        }
    }

    override fun onDeleteClick() {
        _detailSportActivityUIState.value = _detailSportActivityUIState.value.copy(
            showDeleteDialog = true
        )
    }

    override fun onDeleteConfirm() {
        val sportToDelete = _detailSportActivityUIState.value.sport ?: return
        viewModelScope.launch {
            repository.delete(sportToDelete)
            _detailSportActivityUIState.value = _detailSportActivityUIState.value.copy(
                sportActivityDeleted = true,
                showDeleteDialog = false
            )
        }
    }

    override fun onDeleteDismiss() {
        _detailSportActivityUIState.value = _detailSportActivityUIState.value.copy(
            showDeleteDialog = false
        )
    }
}