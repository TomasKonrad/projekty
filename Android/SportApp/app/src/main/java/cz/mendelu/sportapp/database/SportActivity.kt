package cz.mendelu.sportapp.database

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsBike
import androidx.compose.material.icons.automirrored.filled.DirectionsRun
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material.icons.filled.Pool
import androidx.compose.ui.graphics.vector.ImageVector

enum class SportActivity(val type: String, val icon: ImageVector){
    RUN("běh", Icons.AutoMirrored.Filled.DirectionsRun),
    BIKE("kolo", Icons.AutoMirrored.Filled.DirectionsBike),
    SWIMMING("plavání", Icons.Default.Pool),
    GYM("posilovna", Icons.Default.FitnessCenter)
}