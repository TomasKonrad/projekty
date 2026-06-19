package cz.mendelu.gtagarage.ui.screens.AddEditCar

import android.net.Uri
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.OwnedGarage
import cz.mendelu.gtagarage.database.model.VehicleClass

data class AddEditCarUIState(
    val car: Car = Car("", "", VehicleClass.SPORTS, 0, 0.0, "", "", "" ),
    val selectedImageUri: Uri? = null,
    val existingImagePath: String = "",

    val garages: List<OwnedGarage> = emptyList(),

    val nameError: Int? = null,
    val brandError: Int? = null,

    val maxSpeedInput: String = "",
    val maxSpeedError: Int? = null,

    val purchasePriceInput: String = "",
    val purchasePriceError: Int? = null,

    val garageCapacityError: Int? = null,

    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val isEditMode: Boolean = false,

    val noInternetError: Int? = null,
    val showErrorSnackbar: Boolean = false
)