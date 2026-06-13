import Combine

enum AuthViewState {
    case idle
    case loading
    case success(isNewUser: Bool)
    case failure(String)
}

final class AuthViewModel: ObservableObject {
    @Published var viewState: AuthViewState = .idle

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    func signIn(idToken: String, name: String? = nil, avatarURL: String? = nil) {
        perform { [weak self] in
            try await self?.loginUseCase.execute(idToken: idToken, name: name, avatarURL: avatarURL)
        }
    }

    private func perform(_ work: @escaping () async throws -> Session?) {
        viewState = .loading
        Task {
            do {
                guard let session = try await work() else { return }
                await MainActor.run { viewState = .success(isNewUser: session.isNewUser) }
            } catch {
                await MainActor.run { viewState = .failure(error.localizedDescription) }
            }
        }
    }

    func signInWithApple(identityToken: String, name: String?) {
        viewState = .loading
        Task {
            do {
                let session = try await loginUseCase.executeApple(identityToken: identityToken, name: name)
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

    func handleAppleError(_ message: String) {
        viewState = .failure("Apple 登录失败：\(message)")
    }
}
