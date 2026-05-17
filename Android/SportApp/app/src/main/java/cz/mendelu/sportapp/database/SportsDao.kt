package cz.mendelu.sportapp.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface SportsDao {
    @Insert
    suspend fun insert(sport: Sport): Long

    @Query("SELECT * FROM sports ORDER BY id DESC")
    fun getAll(): Flow<List<Sport>>

    @Update
    suspend fun update(sport: Sport)

    @Query("SELECT * FROM sports WHERE id = :id")
    suspend fun getById(id: Long): Sport
    @Query("SELECT * FROM sports WHERE id = :id")
    fun getByIdFlow(id: Long): Flow<Sport?>

    @Query("SELECT COUNT(*) FROM sports")
    suspend fun getCountOfActivities() : Int

    @Query("SELECT SUM(durationInMinutes) FROM sports")
    suspend fun getAllMinutes() : Int?

    @Query("SELECT typeOfActivity FROM sports GROUP BY typeOfActivity ORDER BY COUNT(*) DESC LIMIT 1")
    suspend fun getMostCommonActivity(): String?

    @Delete
    suspend fun delete(sport: Sport)
}