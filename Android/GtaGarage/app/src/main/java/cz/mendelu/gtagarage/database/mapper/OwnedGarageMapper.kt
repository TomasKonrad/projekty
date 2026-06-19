package cz.mendelu.gtagarage.database.mapper

import cz.mendelu.gtagarage.database.model.OwnedGarage
import cz.mendelu.gtagarage.database.model.OwnedGarageEntity

object OwnedGarageMapper {
    fun OwnedGarageEntity.toDomain(): OwnedGarage {
        return OwnedGarage(
            garageId = garageId,
            garageName = garageName,
            garageLocationName = garageLocationName,
            garageCapacity = garageCapacity,
            garagePurchasePrice = garagePurchasePrice
        )
    }

    fun OwnedGarage.toEntity(userId: String): OwnedGarageEntity {
        return OwnedGarageEntity(
            garageId = garageId,
            userId = userId,
            garageName = garageName,
            garageLocationName = garageLocationName,
            garageCapacity = garageCapacity,
            garagePurchasePrice = garagePurchasePrice
        )
    }
}