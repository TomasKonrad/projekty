package cz.mendelu.sportapp.ui.screens.elements

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import cz.mendelu.sportapp.ui.screens.elements.PlaceholderScreenContent
import cz.mendelu.sportapp.ui.theme.Dimens.basicMargin
import cz.mendelu.sportapp.ui.theme.Dimens.halfMargin

@Composable
fun PlaceholderScreen(
    paddingValues: PaddingValues,
    placeholderScreenContent: PlaceholderScreenContent,
    horizontalMargin: Dp = basicMargin
){
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
            .padding(horizontal = horizontalMargin),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (placeholderScreenContent.image != null) {
                Image(
                    painter = painterResource(placeholderScreenContent.image),
                    contentDescription = placeholderScreenContent.text?.let {
                        stringResource(it)
                    },
                    contentScale = ContentScale.FillWidth,
                    modifier = Modifier.fillMaxWidth(0.6f)
                )
            }
            if (placeholderScreenContent.image != null && placeholderScreenContent.text != null){
                Spacer(modifier =Modifier.height(halfMargin))
            }
            if (placeholderScreenContent.text != null){
                Text(
                    text = stringResource(placeholderScreenContent.text),
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center
                )
            }
        }
    }

}