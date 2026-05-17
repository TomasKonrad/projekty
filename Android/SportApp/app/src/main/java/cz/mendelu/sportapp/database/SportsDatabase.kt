package cz.mendelu.sportapp.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [Sport::class], version = 1, exportSchema = true)
abstract class SportsDatabase : RoomDatabase() {
    abstract fun sportsDao() : SportsDao

    companion object {
        private var instance: SportsDatabase? = null

        fun getDatabase(context: Context): SportsDatabase{
            if (instance == null) {
                synchronized(SportsDatabase::class.java){
                    if (instance ==null) {
                        instance = Room.databaseBuilder(
                            context.applicationContext,
                            SportsDatabase::class.java,
                            "database"
                        ).build()
                    }
                }
            }
            return instance!!
        }
    }
}