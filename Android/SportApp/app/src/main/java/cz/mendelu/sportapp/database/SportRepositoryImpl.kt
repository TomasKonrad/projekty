package cz.mendelu.sportapp.database

import kotlinx.coroutines.flow.Flow

class SportRepositoryImpl(private val dao: SportsDao) : ISportRepository {
    override suspend fun insert(sport: Sport): Long = dao.insert(sport)

    override fun getAll(): Flow<List<Sport>> = dao.getAll()

    override suspend fun update(sport: Sport) = dao.update(sport)

    override fun getByIdFlow(id: Long): Flow<Sport?> = dao.getByIdFlow(id)

    override suspend fun getById(id: Long): Sport = dao.getById(id)

    override suspend fun getCountOfActivities(): Int = dao.getCountOfActivities()

    override suspend fun getAllMinutes(): Int? = dao.getAllMinutes()

    override suspend fun getMostCommonActivity(): String? = dao.getMostCommonActivity()

    override suspend fun delete(sport: Sport) = dao.delete(sport)
}