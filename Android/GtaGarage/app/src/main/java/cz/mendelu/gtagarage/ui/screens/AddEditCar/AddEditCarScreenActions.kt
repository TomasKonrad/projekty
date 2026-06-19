package cz.mendelu.gtagarage.ui.screens.AddEditCar

import android.net.Uri
import cz.mendelu.gtagarage.database.model.VehicleClass

interface AddEditCarScreenActions {
    fun onNameChanged(name: String)
    fun onBrandChanged(brand: String)
    fun onVehicleClassChanged(vehicleClass: VehicleClass)
    fun onMaxSpeedChanged(maxSpeed: String)
    fun onPurchasePriceChanged(purchasePrice: String)
    fun onDescriptionChanged(description: String)
    fun onGarageSelected(garageId: String)
    fun onImageSelected(uri: Uri?)
    fun saveCar()
}