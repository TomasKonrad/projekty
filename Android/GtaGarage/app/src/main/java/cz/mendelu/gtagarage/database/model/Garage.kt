package cz.mendelu.gtagarage.database.model

import com.google.firebase.firestore.DocumentId

data class Garage(
    @DocumentId
    val id: String = "",
    val name: String = "",
    val locationName: String = "",
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val capacity: Int = 0,
    val purchasePrice: Double = 0.0,
    val description: String = "",
    val imagePath: String = ""
)