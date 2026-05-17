package cz.mendelu.sportapp.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sports")
data class Sport(
    var title: String,
    var place: String,
    var durationInMinutes: Int,
    var burnedCalories: Double,
    val typeOfActivity: SportActivity,
    var description: String?,
    @PrimaryKey(autoGenerate = true)
    var id: Long? = null
)
