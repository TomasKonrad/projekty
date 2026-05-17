package cz.mendelu.sportapp.database

import kotlinx.coroutines.flow.Flow

interface ISportRepository {
    suspend fun insert(sport: Sport): Long
    fun getAll(): Flow<List<Sport>>
    suspend fun update(sport: Sport)
    fun getByIdFlow(id: Long): Flow<Sport?>
    suspend fun getById(id:Long): Sport

    suspend fun getCountOfActivities() : Int

    suspend fun getAllMinutes() : Int?

    suspend fun getMostCommonActivity(): String?

    suspend fun delete(sport: Sport)
}