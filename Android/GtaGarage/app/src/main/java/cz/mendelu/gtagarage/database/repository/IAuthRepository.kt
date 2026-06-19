package cz.mendelu.gtagarage.database.repository

interface IAuthRepository {
    suspend fun signInAnonymouslyIfNeeded(): Result<String>
    fun getCurrentUserId(): String?
    suspend fun getOrCreateUserId(): String
}