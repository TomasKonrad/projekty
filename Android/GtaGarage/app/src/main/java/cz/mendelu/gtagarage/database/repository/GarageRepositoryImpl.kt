package cz.mendelu.gtagarage.database.repository

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.toObjects
import cz.mendelu.gtagarage.database.model.Garage
import cz.mendelu.gtagarage.database.model.OwnedGarage
import cz.mendelu.gtagarage.database.dao.GarageDao
import cz.mendelu.gtagarage.database.dao.OwnedGarageDao
import cz.mendelu.gtagarage.database.datastore.AppDataStore
import cz.mendelu.gtagarage.database.mapper.GarageMapper.toDomain
import cz.mendelu.gtagarage.database.mapper.GarageMapper.toEntity
import cz.mendelu.gtagarage.database.mapper.OwnedGarageMapper.toDomain
import cz.mendelu.gtagarage.database.mapper.OwnedGarageMapper.toEntity
import jakarta.inject.Inject
import jakarta.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withTimeout

@Singleton
class GarageRepositoryImpl @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val garageDao: GarageDao,
    private val ownedGarageDao: OwnedGarageDao,
    private val appDataStore: AppDataStore
) : IGarageRepository {

    private val garagesCollection = firestore.collection("garages")
    private val usersCollection = firestore.collection("users")

    override fun getAllGarages(): Flow<List<Garage>> {
        return garageDao.getAllGarages()
            .map { entities -> entities.map { it.toDomain() } }
    }

    override fun getOwnedGarages(userId: String): Flow<List<OwnedGarage>> {
        return ownedGarageDao.getOwnedGarages(userId)
            .map { entities -> entities.map { it.toDomain() } }
    }

    override fun getGarageDetail(garageId: String): Flow<Garage?> {
        return garageDao.getGarageDetail(garageId)
            .map { it?.toDomain() }
    }

    override suspend fun getGarageMarkerDetail(garageId: String): Garage? {
        return garageDao.getGarageOnce(garageId)?.toDomain()
    }

    override suspend fun addGarageToOwned(userId: String, garage: Garage) {
        val ownedGarage = OwnedGarage(
            garageId = garage.id,
            garageName = garage.name,
            garageLocationName = garage.locationName,
            garageCapacity = garage.capacity,
            garagePurchasePrice = garage.purchasePrice
        )

        withTimeout(1000L) {
            usersCollection
                .document(userId)
                .collection("owned_garages")
                .document(garage.id)
                .set(ownedGarage)
                .await()
        }
        ownedGarageDao.upsertOwnedGarage(ownedGarage.toEntity(userId))
    }

    override suspend fun syncGarages() {
        try {
            val snapshot = garagesCollection.get().await()
            val entities = snapshot.toObjects<Garage>()
                .map { it.toEntity() }
            garageDao.upsertGarages(entities)
            appDataStore.saveLastSyncTimestamp(System.currentTimeMillis())
        } catch (e: Exception) { }
    }

    override suspend fun syncOwnedGarages(userId: String) {
        try {
            val snapshot = usersCollection
                .document(userId)
                .collection("owned_garages")
                .get()
                .await()
            val entities = snapshot.toObjects<OwnedGarage>()
                .map { it.toEntity(userId) }
            ownedGarageDao.upsertOwnedGarages(entities)
        } catch (e: Exception) { }
    }

    override suspend fun deleteOwnedGarage(userId: String, garageId: String) {
        withTimeout(1000L) {
            usersCollection
                .document(userId)
                .collection("owned_garages")
                .document(garageId)
                .delete()
                .await()
        }

        ownedGarageDao.deleteOwnedGarage(garageId, userId)
    }

    override suspend fun getTotalGaragesCount(userId: String): Int {
        return ownedGarageDao.getTotalGaragesCount(userId)
    }

    override suspend fun getTotalGaragesValue(userId: String): Double {
        return ownedGarageDao.getTotalGaragesValue(userId) ?: 0.0
    }
}