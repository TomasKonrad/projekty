package cz.mendelu.gtagarage.database.repository

import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.database.model.OwnedGarage
import kotlinx.coroutines.flow.Flow

interface IGarageRepository {
    fun getAllGarages(): Flow<List<Garage>>
    fun getOwnedGarages(userId: String): Flow<List<OwnedGarage>>
    fun getGarageDetail(garageId: String): Flow<Garage?>
    suspend fun getGarageMarkerDetail(garageId: String): Garage?
    suspend fun addGarageToOwned(userId: String, garage: Garage)
    suspend fun syncGarages()
    suspend fun syncOwnedGarages(userId: String)
    suspend fun deleteOwnedGarage(userId: String, garageId: String)
    suspend fun getTotalGaragesCount(userId: String): Int
    suspend fun getTotalGaragesValue(userId: String): Double
}