final class AppDI {
    static let shared = AppDI()

    private lazy var apiClient = APIClient.shared

    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository(apiClient: apiClient)
    private lazy var channelRepository: ChannelRepositoryProtocol = ChannelRepository(apiClient: apiClient)
    private lazy var userRepository: UserRepositoryProtocol = UserRepository(apiClient: apiClient)

    private lazy var loginUseCase = LoginUseCase(repository: authRepository)

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(loginUseCase: loginUseCase)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(channelRepository: channelRepository)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(channelRepository: channelRepository, userRepository: userRepository)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(userRepository: userRepository)
    }

    func makeVoiceRoomViewModel(channel: Channel) -> VoiceRoomViewModel {
        VoiceRoomViewModel(channel: channel, userRepository: userRepository)
    }

    func makeBlockedUsersViewModel() -> BlockedUsersViewModel {
        BlockedUsersViewModel(userRepository: userRepository)
    }
}
