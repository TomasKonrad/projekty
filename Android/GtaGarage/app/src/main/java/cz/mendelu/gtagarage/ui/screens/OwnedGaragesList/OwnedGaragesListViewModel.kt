package cz.mendelu.gtagarage.ui.screens.OwnedGaragesList

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cz.mendelu.gtagarage.database.NetworkMonitor
import cz.mendelu.gtagarage.database.repository.IAppInfoRepository
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class OwnedGaragesListViewModel @Inject constructor(
    private val repository: IGarageRepository,
    private val authRepository: IAuthRepository,
    private val networkMonitor: NetworkMonitor,
    private val appInfoRepository: IAppInfoRepository
) : ViewModel() {

    private val _ownedGarageListUIState = MutableStateFlow(OwnedGaragesListUIState())
    val ownedGarageListUIState = _ownedGarageListUIState.asStateFlow()

    init {
        loadAppVersion()
        viewModelScope.launch {
            networkMonitor.isOnline.collect { isOnline ->
                if (isOnline) {
                    loadOwnedGarages()
                } else {
                    loadOwnedGaragesFromCache()
                }
            }
        }
    }

    private fun loadAppVersion() {
        _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
            appVersion = appInfoRepository.getAppVersion()
        )
    }

    private fun loadOwnedGarages() {
        viewModelScope.launch {
            val userId = authRepository.getOrCreateUserId()

            if (userId.isEmpty()) {
                _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
                    isLoading = false,
                    isOfflineFirstLaunch = true
                )
            } else {
                _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
                    isOfflineFirstLaunch = false
                )

                launch { repository.syncOwnedGarages(userId) }

                repository.getOwnedGarages(userId).collect { ownedGarages ->
                    _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
                        ownedGarages = ownedGarages,
                        isLoading = false
                    )
                }
            }
        }
    }

    private fun loadOwnedGaragesFromCache() {
        viewModelScope.launch {
            val userId = authRepository.getOrCreateUserId()

            if (userId.isEmpty()) {
                _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
                    isLoading = false,
                    isOfflineFirstLaunch = true
                )
            } else {
                repository.getOwnedGarages(userId).collect { ownedGarages ->
                    _ownedGarageListUIState.value = _ownedGarageListUIState.value.copy(
                        ownedGarages = ownedGarages,
                        isLoading = false,
                        isOfflineFirstLaunch = false
                    )
                }
            }
        }
    }
}