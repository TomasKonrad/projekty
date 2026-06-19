package cz.mendelu.gtagarage.database.repository

import android.content.Context
import android.net.Uri
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.toObjects
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.dao.CarDao
import cz.mendelu.gtagarage.database.mapper.CarMapper.toDomain
import cz.mendelu.gtagarage.database.mapper.CarMapper.toEntity
import cz.mendelu.gtagarage.database.model.BrandCount
import cz.mendelu.gtagarage.database.model.VehicleClassCount
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withTimeout
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CarRepositoryImpl @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val carDao: CarDao,
    @ApplicationContext private val context: Context
) : ICarRepository {
    private val usersCollection = firestore.collection("users")
    private fun carsCollection(userId: String) =
        usersCollection.document(userId).collection("cars")

    private fun copyImageToFilesDir(sourceUri: Uri, carId: String): String {
        val carsDir = File(context.filesDir, "cars").also { it.mkdirs() }
        val destFile = File(carsDir, "$carId.jpg")
        context.contentResolver.openInputStream(sourceUri)?.use { input ->
            destFile.outputStream().use { output -> input.copyTo(output) }
        }
        return destFile.absolutePath
    }

    private fun deleteImageFromFilesDir(imagePath: String) {
        if (imagePath.isNotEmpty()) {
            File(imagePath).takeIf { it.exists() }?.delete()
        }
    }

    override fun getCarsInGarage(userId: String, garageId: String): Flow<List<Car>> {
        return carDao.getCarsInGarage(userId, garageId)
            .map { entities -> entities.map { it.toDomain() } }
    }

    override suspend fun getCarCountInGarage(userId: String, garageId: String): Int {
        return carDao.getCarCountInGarage(userId, garageId)
    }

    override fun getCarDetail(userId: String, carId: String): Flow<Car?> {
        return carDao.getCarDetail(userId, carId)
            .map { it?.toDomain() }
    }

    override suspend fun addCar(userId: String, car: Car, imageUri: Uri?) {
        val newCarId = carsCollection(userId).document().id
        val imagePath = imageUri?.let { copyImageToFilesDir(it, newCarId) } ?: ""

        val newCar = Car(
            id = newCarId,
            brand = car.brand,
            name = car.name,
            vehicleClass = car.vehicleClass,
            maxSpeed = car.maxSpeed,
            purchasePrice = car.purchasePrice,
            description = car.description,
            garageId = car.garageId,
            imagePath = imagePath
        )

        withTimeout(2000L) {
            carsCollection(userId).document(newCarId).set(newCar).await()
        }
        carDao.upsertCar(newCar.toEntity(userId))
    }

    override suspend fun updateCar(userId: String, car: Car, newImageUri: Uri?) {
        val imagePath = if (newImageUri != null) {
            deleteImageFromFilesDir(car.imagePath)
            copyImageToFilesDir(newImageUri, car.id)
        } else {
            car.imagePath
        }

        val updatedCar = car.copy(imagePath = imagePath)

        withTimeout(2000L) {
            carsCollection(userId).document(car.id).set(updatedCar).await()
        }
        carDao.upsertCar(updatedCar.toEntity(userId))
    }

    override suspend fun deleteCar(userId: String, car: Car) {
        withTimeout(1000L) {
            carsCollection(userId).document(car.id).delete().await()
        }
        deleteImageFromFilesDir(car.imagePath)
        carDao.deleteCar(car.id)
    }

    override suspend fun syncCars(userId: String, garageId: String) {
        try {
            val snapshot = carsCollection(userId)
                .whereEqualTo("garageId", garageId)
                .get()
                .await()
            val entities = snapshot.toObjects<Car>()
                .map { it.toEntity(userId) }
            carDao.upsertCars(entities)
        } catch (e: Exception) {}
    }

    override suspend fun syncAllCars(userId: String) {
        try {
            val snapshot = carsCollection(userId)
                .get()
                .await()
            val entities = snapshot.toObjects<Car>()
                .map { it.toEntity(userId) }
            carDao.upsertCars(entities)
        } catch (e: Exception) { }
    }

    override suspend fun deleteCarsByGarageId(userId: String, garageId: String) {
        val cars = carDao.getCarsInGarageOnce(userId, garageId)
        cars.forEach { car ->
            deleteImageFromFilesDir(car.imagePath)
        }

        withTimeout(2000L) {
            val snapshot = carsCollection(userId)
                .whereEqualTo("garageId", garageId)
                .get()
                .await()
            snapshot.documents.forEach { it.reference.delete().await() }
        }

        carDao.deleteCarsByGarageId(userId, garageId)

        cars.forEach { car ->
            deleteImageFromFilesDir(car.imagePath)
        }
    }

    override suspend fun getTotalCarsCount(userId: String): Int {
        return carDao.getTotalCarsCount(userId)
    }

    override suspend fun getTotalCarsValue(userId: String): Double {
        return carDao.getTotalCarsValue(userId) ?: 0.0
    }

    override suspend fun getMostExpensiveCar(userId: String): Car? {
        return carDao.getMostExpensiveCar(userId)?.toDomain()
    }

    override suspend fun getFastestCar(userId: String): Car? {
        return carDao.getFastestCar(userId)?.toDomain()
    }

    override suspend fun getCarCountByClass(userId: String): List<VehicleClassCount> {
        return carDao.getCarCountByClass(userId)
    }

    override suspend fun getCarCountByBrand(userId: String): List<BrandCount> {
        return carDao.getCarCountByBrand(userId)
    }
}