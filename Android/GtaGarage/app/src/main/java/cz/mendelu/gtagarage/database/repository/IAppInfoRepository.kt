package cz.mendelu.gtagarage.database.repository

interface IAppInfoRepository {
    fun getAppVersion(): String
}