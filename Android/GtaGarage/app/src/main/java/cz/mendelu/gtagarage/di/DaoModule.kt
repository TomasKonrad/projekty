package cz.mendelu.gtagarage.di

import cz.mendelu.gtagarage.database.AppDatabase
import cz.mendelu.gtagarage.database.dao.CarDao
import cz.mendelu.gtagarage.database.dao.GarageDao
import cz.mendelu.gtagarage.database.dao.OwnedGarageDao
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
    fun provideCarDao(db: AppDatabase): CarDao = db.carDao()

    @Provides
    @Singleton
    fun provideGarageDao(db: AppDatabase): GarageDao = db.garageDao()

    @Provides
    @Singleton
    fun provideOwnedGarageDao(db: AppDatabase): OwnedGarageDao = db.ownedGarageDao()
}