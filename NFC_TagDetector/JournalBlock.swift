

import Foundation

enum JournalBlock: Identifiable, Codable, Equatable {
    case text(id: UUID, content: String)
    case media(id: UUID, mediaIdentifier: String, isVideo: Bool)

    var id: UUID {
        switch self {
        case .text(let id, _), .media(let id, _, _):
            return id
        }
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type, id, content, mediaIdentifier, isVideo
    }

    enum BlockType: String, Codable {
        case text, media
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BlockType.self, forKey: .type)

        switch type {
        case .text:
            let id = try container.decode(UUID.self, forKey: .id)
            let content = try container.decode(String.self, forKey: .content)
            self = .text(id: id, content: content)
        case .media:
            let id = try container.decode(UUID.self, forKey: .id)
            let identifier = try container.decode(String.self, forKey: .mediaIdentifier)
            let isVideo = try container.decode(Bool.self, forKey: .isVideo)
            self = .media(id: id, mediaIdentifier: identifier, isVideo: isVideo)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let id, let content):
            try container.encode(BlockType.text, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(content, forKey: .content)
        case .media(let id, let identifier, let isVideo):
            try container.encode(BlockType.media, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(identifier, forKey: .mediaIdentifier)
            try container.encode(isVideo, forKey: .isVideo)
        }
    }
}
