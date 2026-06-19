package cz.mendelu.gtagarage.database.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "owned_garages")
data class OwnedGarageEntity(
    val userId: String,
    val garageName: String,
    val garageLocationName: String,
    val garageCapacity: Int,
    val garagePurchasePrice: Double,
    @PrimaryKey
    val garageId: String
)