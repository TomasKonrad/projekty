package cz.mendelu.gtagarage.database.mapper

import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.database.model.GarageEntity

object GarageMapper {
    fun GarageEntity.toDomain(): Garage {
        return Garage(
            id = id,
            name = name,
            locationName = locationName,
            latitude = latitude,
            longitude = longitude,
            capacity = capacity,
            purchasePrice = purchasePrice,
            description = description,
            imagePath = imagePath
        )
    }

    fun Garage.toEntity(): GarageEntity {
        return GarageEntity(
            id = id,
            name = name,
            locationName = locationName,
            latitude = latitude,
            longitude = longitude,
            capacity = capacity,
            purchasePrice = purchasePrice,
            description = description,
            imagePath = imagePath
        )
    }
}