package cz.mendelu.gtagarage.database.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "cars")
data class CarEntity(
    val userId: String,
    val name: String,
    val brand: String,
    val vehicleClass: String,
    val maxSpeed: Int,
    val purchasePrice: Double,
    val description: String,
    val garageId: String,
    val imagePath: String,
    @PrimaryKey
    val id: String,
)
