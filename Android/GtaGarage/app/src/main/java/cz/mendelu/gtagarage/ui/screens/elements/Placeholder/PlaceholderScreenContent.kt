package cz.mendelu.gtagarage.ui.screens.elements.Placeholder

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

data class PlaceholderScreenContent(
    @DrawableRes val image: Int? = null,
    @StringRes val text: Int? = null,
    val lottieAnimation: String? = null
) {
    init {
        require(image != null || text != null || lottieAnimation != null) {
            "PlaceholderScreenContent must contain at least an image, animation or text"
        }
    }
}