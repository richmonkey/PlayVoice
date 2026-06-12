import Foundation
import Combine

enum SearchViewState {
    case idle
    case searching
    case loaded([SearchUser])
    case empty
    case failure(String)
}

final class SearchViewModel: ObservableObject {
    @Published private(set) var viewState: SearchViewState = .idle

    private let userRepository: UserRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func search(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            viewState = .idle
            return
        }
        viewState = .searching
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            do {
                let users = try await userRepository.searchUsers(query: trimmed)
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.viewState = users.isEmpty ? .empty : .loaded(users)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .failure(error.localizedDescription)
                }
            }
        }
    }

    func toggleFollow(userId: Int) {
        guard case .loaded(let users) = viewState,
              let user = users.first(where: { $0.userId == userId }) else { return }

        Task {
            do {
                if user.isFollowed {
                    try await userRepository.unfollowUser(userId: userId)
                } else {
                    try await userRepository.followUser(userId: userId)
                }
                await MainActor.run {
                    if case .loaded(var list) = self.viewState,
                       let idx = list.firstIndex(where: { $0.userId == userId }) {
                        list[idx].isFollowed.toggle()
                        self.viewState = .loaded(list)
                    }
                }
            } catch {
                // follow/unfollow error — silently ignore for now
            }
        }
    }
}
