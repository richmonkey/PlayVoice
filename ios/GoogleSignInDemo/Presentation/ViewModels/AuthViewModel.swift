import Combine

enum AuthViewState {
    case idle
    case loading
    case success(isNewUser: Bool)
    case failure(String)
}

final class AuthViewModel: ObservableObject {
    @Published private(set) var viewState: AuthViewState = .idle

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    func signIn(idToken: String, name: String? = nil, avatarURL: String? = nil) {
        viewState = .loading
        Task {
            do {
                let session = try await loginUseCase.execute(idToken: idToken, name: name, avatarURL: avatarURL)
                await MainActor.run {
                    viewState = .success(isNewUser: session.isNewUser)
                }
            } catch {
                await MainActor.run {
                    viewState = .failure(error.localizedDescription)
                }
            }
        }
    }
}
