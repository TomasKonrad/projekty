package cz.mendelu.gtagarage.database

import androidx.room.Database
import androidx.room.RoomDatabase
import cz.mendelu.gtagarage.database.dao.CarDao
import cz.mendelu.gtagarage.database.dao.GarageDao
import cz.mendelu.gtagarage.database.dao.OwnedGarageDao
import cz.mendelu.gtagarage.database.model.CarEntity
import cz.mendelu.gtagarage.database.model.GarageEntity
import cz.mendelu.gtagarage.database.model.OwnedGarageEntity

@Database(
    entities = [CarEntity::class, GarageEntity::class, OwnedGarageEntity::class],
    version = 3,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun carDao(): CarDao
    abstract fun garageDao(): GarageDao
    abstract fun ownedGarageDao(): OwnedGarageDao
}