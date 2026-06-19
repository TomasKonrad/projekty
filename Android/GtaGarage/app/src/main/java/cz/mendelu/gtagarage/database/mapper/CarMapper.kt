package cz.mendelu.gtagarage.database.mapper

import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.VehicleClass
import cz.mendelu.gtagarage.database.model.CarEntity

object CarMapper {
    fun CarEntity.toDomain(): Car {
        return Car(
            id = id,
            name = name,
            brand = brand,
            vehicleClass = VehicleClass.valueOf(vehicleClass),
            maxSpeed = maxSpeed,
            purchasePrice = purchasePrice,
            description = description,
            garageId = garageId,
            imagePath = imagePath
        )
    }

    fun Car.toEntity(userId: String): CarEntity {
        return CarEntity(
            id = id,
            userId = userId,
            name = name,
            brand = brand,
            vehicleClass = vehicleClass.name,
            maxSpeed = maxSpeed,
            purchasePrice = purchasePrice,
            description = description,
            garageId = garageId,
            imagePath = imagePath
        )
    }
}