package cz.mendelu.gtagarage.database.repository

import com.google.firebase.auth.FirebaseAuth
import cz.mendelu.gtagarage.database.datastore.AppDataStore
import jakarta.inject.Inject
import jakarta.inject.Singleton
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.tasks.await

@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val auth: FirebaseAuth,
    private val appDataStore: AppDataStore
) : IAuthRepository {
    override suspend fun signInAnonymouslyIfNeeded(): Result<String> {
        return try {
            val currentUser = auth.currentUser
            if (currentUser != null) {
                Result.success(currentUser.uid)
            } else {
                val authResult = auth.signInAnonymously().await()
                val user = authResult.user

                if (user != null) {
                    Result.success(user.uid)
                } else {
                    Result.failure(Exception("Přihlášení se nezdařilo - uživatel je null"))
                }
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun getCurrentUserId(): String? = auth.currentUser?.uid

    override suspend fun getOrCreateUserId(): String {
        val storedId = appDataStore.userId.first()
        if (storedId != null) return storedId

        return try {
            val result = signInAnonymouslyIfNeeded()
            val userId = result.getOrThrow()
            appDataStore.saveUserId(userId)
            userId
        } catch (e: Exception) {
            ""
        }
    }

}