import Foundation

struct AuthMapper {
    static func toEntity(_ dto: AuthResponseDTO) -> Session {
        Session(
            accessToken: dto.accessToken,
            userId: dto.userId,
            name: dto.name ?? "匿名用户",
            email: dto.email,
            avatarURL: dto.avatarUrl.flatMap(URL.init),
            isNewUser: dto.isNewUser
        )
    }
}
