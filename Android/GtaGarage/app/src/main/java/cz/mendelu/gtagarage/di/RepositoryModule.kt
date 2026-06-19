package cz.mendelu.gtagarage.di

import android.content.Context
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import cz.mendelu.gtagarage.database.NetworkMonitor
import cz.mendelu.gtagarage.database.repository.GarageRepositoryImpl
import cz.mendelu.gtagarage.database.repository.IAuthRepository
import cz.mendelu.gtagarage.database.repository.AuthRepositoryImpl
import cz.mendelu.gtagarage.database.repository.CarRepositoryImpl
import cz.mendelu.gtagarage.database.repository.ICarRepository
import cz.mendelu.gtagarage.database.repository.IGarageRepository
import cz.mendelu.gtagarage.database.dao.CarDao
import cz.mendelu.gtagarage.database.dao.GarageDao
import cz.mendelu.gtagarage.database.dao.OwnedGarageDao
import cz.mendelu.gtagarage.database.datastore.AppDataStore
import cz.mendelu.gtagarage.database.repository.AppInfoRepositoryImpl
import cz.mendelu.gtagarage.database.repository.IAppInfoRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {
    @Provides
    @Singleton
    fun provideAppInfoRepository(
        @ApplicationContext context: Context
    ): IAppInfoRepository {
        return AppInfoRepositoryImpl(context)
    }

    @Provides
    @Singleton
    fun provideAuthRepository(
        auth: FirebaseAuth,
        appDataStore: AppDataStore
    ): IAuthRepository {
        return AuthRepositoryImpl(auth, appDataStore)
    }

    @Provides
    @Singleton
    fun provideGarageRepository(
        firestore: FirebaseFirestore,
        garageDao: GarageDao,
        ownedGarageDao: OwnedGarageDao,
        appDataStore: AppDataStore
    ): IGarageRepository {
        return GarageRepositoryImpl(firestore, garageDao, ownedGarageDao, appDataStore)
    }

    @Provides
    @Singleton
    fun provideCarRepository(
        firestore: FirebaseFirestore,
        carDao: CarDao,
        @ApplicationContext context: Context
    ): ICarRepository {
        return CarRepositoryImpl(firestore, carDao, context)
    }
}