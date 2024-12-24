import Foundation

final class ArticleManager {
    private var articles: [ArticleModel] = []

    // MARK: Public Methods

    func getArticles() -> [ArticleModel] {
        return articles
    }

    func fetchArticles(completion: @escaping (Result<[ArticleModel], Error>) -> Void) {
        let rubricId = Constants.RubricId
        let pageSize = Constants.PageSize
        let pageIndex = Constants.PageIndex
        let urlString = "https://news.myseldon.com/api/Section?rubricId=\(rubricId)&pageSize=\(pageSize)&pageIndex=\(pageIndex)"

        guard let url = URL(string: urlString) else {
            completion(.failure(Constants.invalidURLError))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let self = self, let data = data else {
                completion(.failure(Constants.noDataError))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SeldonNewsResponse.self, from: data)
                self.articles = decodedResponse.news
                completion(.success(self.articles))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Constants

    private enum Constants {
        static let RubricId = 4
        static let PageSize = 8
        static let PageIndex = 1

        static let invalidURLError = NSError(domain: "InvalidURL", code: 0, userInfo: nil)
        static let noDataError = NSError(domain: "NoData", code: 0, userInfo: nil)
    }
}
