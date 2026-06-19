package cz.mendelu.gtagarage.database.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "garages")
data class GarageEntity(
    val name: String,
    val locationName: String,
    val latitude: Double,
    val longitude: Double,
    val capacity: Int,
    val purchasePrice: Double,
    val description: String,
    val imagePath: String,
    @PrimaryKey
    val id: String
)