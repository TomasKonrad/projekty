package cz.mendelu.sportapp.di

import android.content.Context
import cz.mendelu.sportapp.database.SportsDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): SportsDatabase{
        return SportsDatabase.getDatabase(context)
    }
}
