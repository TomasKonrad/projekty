package cz.mendelu.gtagarage.database.repository

import android.net.Uri
import cz.mendelu.gtagarage.database.model.BrandCount
import cz.mendelu.gtagarage.database.model.Car
import cz.mendelu.gtagarage.database.model.VehicleClassCount
import kotlinx.coroutines.flow.Flow

interface ICarRepository {
    fun getCarsInGarage(userId: String, garageId: String): Flow<List<Car>>
    suspend fun getCarCountInGarage(userId: String, garageId: String): Int
    fun getCarDetail(userId: String, carId: String): Flow<Car?>
    suspend fun addCar(userId: String, car: Car, imageUri: Uri?)
    suspend fun updateCar(userId: String, car: Car, newImageUri: Uri?)
    suspend fun deleteCar(userId: String, car: Car)
    suspend fun syncCars(userId: String, garageId: String)

    suspend fun syncAllCars(userId: String)
    suspend fun deleteCarsByGarageId(userId: String, garageId: String)

    suspend fun getTotalCarsCount(userId: String): Int
    suspend fun getTotalCarsValue(userId: String): Double
    suspend fun getMostExpensiveCar(userId: String): Car?
    suspend fun getFastestCar(userId: String): Car?

    suspend fun getCarCountByClass(userId: String): List<VehicleClassCount>
    suspend fun getCarCountByBrand(userId: String): List<BrandCount>
}