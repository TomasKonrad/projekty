package cz.mendelu.sportapp.di

import cz.mendelu.sportapp.database.ISportRepository
import cz.mendelu.sportapp.database.SportRepositoryImpl
import cz.mendelu.sportapp.database.SportsDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {
    @Provides
    @Singleton
    fun provideTasksRepository(dao: SportsDao): ISportRepository{
        return SportRepositoryImpl(dao)
    }
}
