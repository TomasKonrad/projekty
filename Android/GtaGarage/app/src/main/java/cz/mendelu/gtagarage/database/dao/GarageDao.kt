package cz.mendelu.gtagarage.database.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import cz.mendelu.gtagarage.database.model.GarageEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface GarageDao {
        @Query("SELECT * FROM garages")
        fun getAllGarages(): Flow<List<GarageEntity>>

        @Query("SELECT * FROM garages WHERE id = :garageId")
        fun getGarageDetail(garageId: String): Flow<GarageEntity?>

        @Query("SELECT * FROM garages WHERE id = :garageId")
        suspend fun getGarage(garageId: String): GarageEntity?

        @Query("SELECT * FROM garages WHERE id = :garageId")
        suspend fun getGarageOnce(garageId: String): GarageEntity?

        @Upsert
        suspend fun upsertGarages(garages: List<GarageEntity>)

        @Query("DELETE FROM owned_garages WHERE garageId = :garageId AND userId = :userId")
        suspend fun deleteOwnedGarage(garageId: String, userId: String)
    }