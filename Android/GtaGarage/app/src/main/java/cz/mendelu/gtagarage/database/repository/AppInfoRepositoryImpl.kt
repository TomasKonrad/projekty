package cz.mendelu.gtagarage.database.repository

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import jakarta.inject.Inject

class AppInfoRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context
) : IAppInfoRepository {
    override fun getAppVersion(): String {
        return context.packageManager
            .getPackageInfo(context.packageName, 0).versionName ?: ""
    }
}