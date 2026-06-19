import Foundation
import Combine

enum BlockedUsersViewState {
    case loading
    case loaded([BlockedUser])
    case failure(String)
}

final class BlockedUsersViewModel: ObservableObject {
    @Published private(set) var viewState: BlockedUsersViewState = .loading

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func load() {
        viewState = .loading
        Task {
            do {
                let users = try await userRepository.fetchBlockedUsers()
                await MainActor.run { self.viewState = .loaded(users) }
            } catch {
                await MainActor.run { self.viewState = .failure(error.localizedDescription) }
            }
        }
    }

    func unblock(userId: Int, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                try await userRepository.unblockUser(userId: userId)
                await MainActor.run {
                    if case .loaded(var list) = self.viewState {
                        list.removeAll { $0.userId == userId }
                        self.viewState = .loaded(list)
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run { completion(false, error.localizedDescription) }
            }
        }
    }
}
