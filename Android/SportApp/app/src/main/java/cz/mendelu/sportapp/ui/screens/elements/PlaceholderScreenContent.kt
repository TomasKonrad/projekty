package cz.mendelu.sportapp.ui.screens.elements

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

data class PlaceholderScreenContent(
    @DrawableRes val image: Int? = null,
    @StringRes val text: Int? = null
) {
    init {
        require(image != null || text != null) {
            "PlaceholderScreenContent must have at least image or text"
        }
    }
}