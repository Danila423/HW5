import Foundation

struct ArticleModel: Decodable {
    let newsId: Int
    let title: String
    let description: String
    let imageUrl: String
    let sourceLink: String
    let fullText: String?

    var fullArticleUrl: URL? {
        return URL(string: sourceLink)
    }

    enum CodingKeys: String, CodingKey {
        case newsId
        case title
        case description = "announce"
        case img
        case sourceLink
        case fullText
    }

    enum ImageContainerKeys: String, CodingKey {
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        newsId = try container.decode(Int.self, forKey: .newsId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        sourceLink = (try? container.decode(String.self, forKey: .sourceLink)) ?? ""
        fullText = try? container.decode(String.self, forKey: .fullText)

        let imgContainer = try container.nestedContainer(keyedBy: ImageContainerKeys.self, forKey: .img)
        imageUrl = (try? imgContainer.decode(String.self, forKey: .url)) ?? ""
    }
}
