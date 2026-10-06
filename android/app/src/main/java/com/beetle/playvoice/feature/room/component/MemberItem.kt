package com.beetle.playvoice.feature.room.component

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.MicOff
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.beetle.playvoice.R
import com.beetle.playvoice.domain.model.Member

private val avatarGradients = listOf(
    listOf(Color(0xFF1B95FF), Color(0xFF47C5FF)),
    listOf(Color(0xFF18A36F), Color(0xFF44D896)),
    listOf(Color(0xFF7A62FF), Color(0xFFAD8EFF)),
    listOf(Color(0xFFFF7A4D), Color(0xFFFFAB6D)),
    listOf(Color(0xFF13B6AF), Color(0xFF51DED8)),
    listOf(Color(0xFFFF5E8F), Color(0xFFFF92B2)),
)

@Composable
fun MemberItem(member: Member, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val background = MaterialTheme.colorScheme.background
    val dark = background.luminance() < 0.5f
    val gradient = avatarGradients[Math.floorMod(member.id.hashCode(), avatarGradients.size)]
    val avatarBorder = when {
        member.speaking -> Color(0xFF0B84FF)
        dark -> Color(0xFF2A4A6A)
        else -> Color(0xFFB7D8F2)
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .height(170.dp)
            .clickable(onClick = onClick)
            .padding(horizontal = 4.dp, vertical = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(Modifier.size(96.dp)) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clip(CircleShape)
                    .background(Brush.linearGradient(gradient))
                    .border(3.dp, avatarBorder, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = initials(member.name),
                    color = Color.White,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                )
            }
            if (member.owner) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .offset(x = (-2).dp, y = (-2).dp)
                        .size(18.dp)
                        .background(Color(0xFF8B73DA), CircleShape)
                        .border(2.dp, background, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_room_crown),
                        contentDescription = "Room owner",
                        tint = Color.White,
                        modifier = Modifier.size(10.dp),
                    )
                }
            }
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .offset(x = 2.dp, y = 2.dp)
                    .size(18.dp)
                    .background(Color(0xFF06A561), CircleShape)
                    .border(2.dp, background, CircleShape),
            )
        }

        Spacer(Modifier.height(10.dp))
        Text(
            text = member.name,
            modifier = Modifier.fillMaxWidth().height(18.dp),
            color = MaterialTheme.colorScheme.onBackground,
            fontSize = 14.sp,
            lineHeight = 18.sp,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            StatusPill(
                modifier = Modifier.weight(1f),
                description = "Online",
                border = if (dark) Color(0xFF1A4A30) else Color(0xFFBFE7D0),
                background = if (dark) Color(0xFF0D2418) else Color(0xFFEFFCF5),
                tint = Color(0xFF06A561),
            )
            StatusPill(
                modifier = Modifier.weight(1f),
                icon = if (member.muted) Icons.Default.MicOff else Icons.Default.Mic,
                description = if (member.muted) "Muted" else "Microphone on",
                border = when {
                    member.muted -> if (dark) Color(0xFF3D2E14) else Color(0xFFEAD4AD)
                    dark -> Color(0xFF1A3550)
                    else -> Color(0xFFB9D8F0)
                },
                background = when {
                    member.muted -> if (dark) Color(0xFF1F1708) else Color(0xFFFFF7E9)
                    dark -> Color(0xFF0D1E30)
                    else -> Color(0xFFEEF6FF)
                },
                tint = when {
                    member.muted -> if (dark) Color(0xFFD4A042) else Color(0xFFC0862B)
                    dark -> Color(0xFF5BAAD4)
                    else -> Color(0xFF4F7CA4)
                },
            )
            StatusPill(
                modifier = Modifier.weight(1f),
                icon = Icons.Default.GraphicEq,
                description = if (member.speaking) "Speaking" else "Not speaking",
                border = when {
                    member.speaking -> if (dark) Color(0xFF1A3D50) else Color(0xFFB8E3FA)
                    dark -> Color(0xFF1E2D3C)
                    else -> Color(0xFFCFE2F2)
                },
                background = when {
                    member.speaking -> if (dark) Color(0xFF0D2130) else Color(0xFFEEF8FF)
                    dark -> Color(0xFF131D26)
                    else -> Color(0xFFF7FBFF)
                },
                tint = when {
                    member.speaking -> Color(0xFF1187FF)
                    dark -> Color(0xFF4A6A7D)
                    else -> Color(0xFF99BAD4)
                },
            )
        }
    }
}

@Composable
private fun StatusPill(
    description: String,
    border: Color,
    background: Color,
    tint: Color,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
) {
    Box(
        modifier = modifier
            .height(22.dp)
            .background(background, CircleShape)
            .border(1.dp, border, CircleShape)
            .semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) {
        if (icon != null) {
            Icon(icon, null, tint = tint, modifier = Modifier.size(11.dp))
        } else {
            androidx.compose.foundation.Canvas(Modifier.size(7.dp)) {
                drawCircle(tint)
            }
        }
    }
}

private fun initials(name: String): String {
    val words = name.trim().split(Regex("\\s+")).filter(String::isNotEmpty)
    fun prefix(value: String, count: Int): String = value.substring(
        0,
        value.offsetByCodePoints(0, minOf(count, value.codePointCount(0, value.length))),
    )
    return if (words.size >= 2) {
        (prefix(words[0], 1) + prefix(words[1], 1)).uppercase()
    } else {
        prefix(words.firstOrNull().orEmpty(), 2).uppercase()
    }
}
