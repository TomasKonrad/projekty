package cz.mendelu.sportapp.ui.screens.elements

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.RowScope
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import cz.mendelu.sportapp.R
import cz.mendelu.sportapp.ui.screens.elements.PlaceholderScreenContent

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BaseScreen(
    topBarText: String,
    onBackClick: (() -> Unit)? = null,
    floatingActionButton: @Composable () -> Unit = {},
    actions: @Composable RowScope.() -> Unit = {},
    content: @Composable (paddingValues: PaddingValues) -> Unit,
    showLoading: Boolean = false,
    placeholderScreenContent: PlaceholderScreenContent? = null
){
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = topBarText,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                },
                navigationIcon = {
                    if (onBackClick !=null) {
                        IconButton(onClick = onBackClick) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = stringResource(R.string.navigate_back)
                            )
                        }
                    }
                },
                actions = actions
            )
        },
        floatingActionButton = floatingActionButton
    ) { paddingValues ->
        when {
            showLoading -> LoadingScreen(paddingValues = paddingValues)
            placeholderScreenContent != null -> PlaceholderScreen(
                paddingValues = paddingValues,
                placeholderScreenContent = placeholderScreenContent
            )
            else -> content(paddingValues)
        }
    }

}
