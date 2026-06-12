import Foundation
import Combine

enum ProfileViewState {
    case loading
    case loaded(channel: Channel, userName: String, email: String, avatarURL: URL?)
    case failure(String)
}

final class ProfileViewModel: ObservableObject {
    @Published private(set) var viewState: ProfileViewState = .loading
    @Published private(set) var isSaving = false

    private let channelRepository: ChannelRepositoryProtocol

    init(channelRepository: ChannelRepositoryProtocol) {
        self.channelRepository = channelRepository
    }

    func load() {
        viewState = .loading
        Task {
            do {
                let channel = try await channelRepository.fetchMyChannel()
                let ud = UserDefaults.standard
                let name = ud.string(forKey: "user_name") ?? ""
                let email = ud.string(forKey: "user_email") ?? ""
                let avatarURL = ud.string(forKey: "user_avatar_url").flatMap(URL.init)
                await MainActor.run {
                    self.viewState = .loaded(channel: channel, userName: name, email: email, avatarURL: avatarURL)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .failure(error.localizedDescription)
                }
            }
        }
    }

    func updateChannelName(_ name: String, completion: @escaping (Bool, String?) -> Void) {
        isSaving = true
        Task {
            do {
                let updated = try await channelRepository.updateChannelName(name)
                await MainActor.run {
                    self.isSaving = false
                    if case .loaded(_, let uName, let email, let avatarURL) = self.viewState {
                        self.viewState = .loaded(channel: updated, userName: uName, email: email, avatarURL: avatarURL)
                    }
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
