package com.beetle.playvoice.app.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.*
import androidx.navigation.toRoute
import com.beetle.playvoice.core.ui.injectedViewModel
import com.beetle.playvoice.domain.repository.*
import com.beetle.playvoice.feature.home.*
import com.beetle.playvoice.feature.moderation.*
import com.beetle.playvoice.feature.profile.*
import com.beetle.playvoice.feature.profile.edit.*
import com.beetle.playvoice.feature.room.*
import com.beetle.playvoice.feature.search.*
import com.beetle.playvoice.feature.settings.*
import com.beetle.playvoice.feature.settings.blocked.*

@Composable
fun AppNavHost(
    account: AccountRepository,
    community: CommunityRepository,
    voice: VoiceRepository,
    sessionKey: String,
) {
    val navigation = rememberNavController()
    val moderation =
        injectedViewModel(key = "moderation:$sessionKey") { ModerationViewModel(community, voice) }
    NavHost(navigation, startDestination = Home) {
        composable<Home> {
            HomeRoute(
                viewModel = injectedViewModel { HomeViewModel(community) },
                onChannel = { navigation.navigate(VoiceRoom(it)) },
                onSearch = { navigation.navigate(Search) },
                onProfile = { navigation.navigate(Profile) },
                onUserActions = moderation::select,
            )
        }
        composable<Search> {
            SearchRoute(
                injectedViewModel { SearchViewModel(community) },
                onBack = { navigation.popBackStack() },
                onUserActions = moderation::select,
            )
        }
        composable<Profile> {
            ProfileRoute(
                injectedViewModel { ProfileViewModel(account, community) },
                onBack = { navigation.popBackStack() },
                onEdit = { navigation.navigate(EditName(it)) },
                onSettings = { navigation.navigate(Settings) },
            )
        }
        composable<EditName> { entry ->
            val route = entry.toRoute<EditName>()
            EditNameRoute(
                injectedViewModel {
                    EditNameViewModel(route.field == "channel", account, community)
                },
                onBack = { navigation.popBackStack() },
            )
        }
        composable<Settings> {
            SettingsRoute(
                injectedViewModel { SettingsViewModel(account) },
                onBack = { navigation.popBackStack() },
                onBlocked = { navigation.navigate(BlockedUsers) },
            )
        }
        composable<BlockedUsers> {
            BlockedUsersRoute(
                injectedViewModel { BlockedUsersViewModel(community) },
                onBack = { navigation.popBackStack() },
            )
        }
        composable<VoiceRoom> { entry ->
            val route = entry.toRoute<VoiceRoom>()
            VoiceRoomRoute(
                injectedViewModel {
                    VoiceRoomViewModel(route.channelId, community, account, voice)
                },
                onBack = { navigation.popBackStack() },
                onUserActions = moderation::select,
            )
        }
    }
    ModerationRoute(moderation)
}
