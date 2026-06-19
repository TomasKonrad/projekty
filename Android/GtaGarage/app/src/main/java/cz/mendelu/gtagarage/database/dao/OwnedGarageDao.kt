package cz.mendelu.gtagarage.database.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import cz.mendelu.gtagarage.database.model.OwnedGarageEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface OwnedGarageDao {

    @Query("SELECT * FROM owned_garages WHERE userId = :userId")
    fun getOwnedGarages(userId: String): Flow<List<OwnedGarageEntity>>

    @Upsert
    suspend fun upsertOwnedGarages(garages: List<OwnedGarageEntity>)
    @Upsert
    suspend fun upsertOwnedGarage(garage: OwnedGarageEntity)

    @Query("DELETE FROM owned_garages WHERE garageId = :garageId AND userId = :userId")
    suspend fun deleteOwnedGarage(garageId: String, userId: String)

    @Query("SELECT COUNT(*) FROM owned_garages WHERE userId = :userId")
    suspend fun getTotalGaragesCount(userId: String): Int

    @Query("SELECT SUM(garagePurchasePrice) FROM owned_garages WHERE userId = :userId")
    suspend fun getTotalGaragesValue(userId: String): Double?
}