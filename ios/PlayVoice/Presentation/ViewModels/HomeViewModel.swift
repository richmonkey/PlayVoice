import Foundation
import Combine

enum HomeViewState {
    case loading
    case loaded(myChannel: Channel?, followed: [Channel])
    case failure(String)
}

final class HomeViewModel: ObservableObject {
    @Published private(set) var viewState: HomeViewState = .loading

    private let channelRepository: ChannelRepositoryProtocol

    init(channelRepository: ChannelRepositoryProtocol) {
        self.channelRepository = channelRepository
    }

    func load() {
        viewState = .loading
        Task {
            do {
                let my = try? await channelRepository.fetchMyChannel()
                let followed = try await channelRepository.fetchFollowedChannels()
                await MainActor.run {
                    self.viewState = .loaded(myChannel: my, followed: followed)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .failure(error.localizedDescription)
                }
            }
        }
    }
}
