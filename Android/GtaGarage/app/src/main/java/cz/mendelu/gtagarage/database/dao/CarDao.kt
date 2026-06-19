package cz.mendelu.gtagarage.database.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import cz.mendelu.gtagarage.database.model.BrandCount
import cz.mendelu.gtagarage.database.model.CarEntity
import cz.mendelu.gtagarage.database.model.VehicleClassCount
import kotlinx.coroutines.flow.Flow

@Dao
interface CarDao {

    @Query("SELECT * FROM cars WHERE userId = :userId AND garageId = :garageId")
    fun getCarsInGarage(userId: String, garageId: String): Flow<List<CarEntity>>

    @Query("SELECT COUNT(*) FROM cars WHERE userId = :userId AND garageId = :garageId")
    suspend fun getCarCountInGarage(userId: String, garageId: String): Int

    @Query("SELECT * FROM cars WHERE userId = :userId AND id = :carId")
    fun getCarDetail(userId: String, carId: String): Flow<CarEntity?>

    @Upsert
    suspend fun upsertCars(cars: List<CarEntity>)

    @Upsert
    suspend fun upsertCar(car: CarEntity)

    @Query("DELETE FROM cars WHERE id = :carId")
    suspend fun deleteCar(carId: String)

    @Query("DELETE FROM cars WHERE userId = :userId AND garageId = :garageId")
    suspend fun deleteCarsByGarageId(userId: String, garageId: String)

    @Query("SELECT * FROM cars WHERE userId = :userId AND garageId = :garageId")
    suspend fun getCarsInGarageOnce(userId: String, garageId: String): List<CarEntity>

    @Query("SELECT COUNT(*) FROM cars WHERE userId = :userId")
    suspend fun getTotalCarsCount(userId: String): Int

    @Query("SELECT SUM(purchasePrice) FROM cars WHERE userId = :userId")
    suspend fun getTotalCarsValue(userId: String): Double?

    @Query("SELECT * FROM cars WHERE userId = :userId ORDER BY purchasePrice DESC LIMIT 1")
    suspend fun getMostExpensiveCar(userId: String): CarEntity?

    @Query("SELECT * FROM cars WHERE userId = :userId ORDER BY maxSpeed DESC LIMIT 1")
    suspend fun getFastestCar(userId: String): CarEntity?

    @Query("SELECT vehicleClass, COUNT(*) as count FROM cars WHERE userId = :userId GROUP BY vehicleClass ORDER BY count DESC")
    suspend fun getCarCountByClass(userId: String): List<VehicleClassCount>

    @Query("SELECT brand, COUNT(*) as count FROM cars WHERE userId = :userId GROUP BY brand ORDER BY count DESC")
    suspend fun getCarCountByBrand(userId: String): List<BrandCount>
}