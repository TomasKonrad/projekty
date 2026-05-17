package cz.mendelu.sportapp.di

import cz.mendelu.sportapp.database.SportsDao
import cz.mendelu.sportapp.database.SportsDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DaoModule {
    @Provides
    @Singleton
    fun provideTaskDuo(sportsDatabase: SportsDatabase) : SportsDao{
        return sportsDatabase.sportsDao()
    }
}
