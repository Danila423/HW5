import Foundation

struct SeldonNewsResponse: Decodable {
    let news: [ArticleModel]
}
