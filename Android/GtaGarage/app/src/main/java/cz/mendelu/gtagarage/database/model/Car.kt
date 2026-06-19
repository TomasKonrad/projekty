package cz.mendelu.gtagarage.database.model

import androidx.room.Entity
import com.google.firebase.firestore.DocumentId

@Entity(tableName = "cars")
data class Car(
    val name: String = "",
    val brand: String = "",
    val vehicleClass: VehicleClass = VehicleClass.SPORTS,
    val maxSpeed: Int = 0,
    val purchasePrice: Double = 0.0,
    val description: String = "",
    val garageId: String = "",
    val imagePath: String = "",
    @DocumentId
    val id: String = "",
)