final class AppDI {
    static let shared = AppDI()

    private lazy var apiClient = APIClient.shared

    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository(apiClient: apiClient)

    private lazy var loginUseCase = LoginUseCase(repository: authRepository)

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(loginUseCase: loginUseCase)
    }
}
