import UIKit

final class NewsViewController: UIViewController {

    private let tableView = UITableView()
    private let articleManager = ArticleManager()

    // MARK: Constants

    private enum Constants {
        static let estimatedRowHeight: CGFloat = 80
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Новости"
        setupTableView()
        fetchData()
    }

    // MARK: Setup TableView

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.register(ArticleCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: Fetch Data

    private func fetchData() {
        articleManager.fetchArticles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showErrorAlert(message: "Не удалось загрузить новости: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Error Handling

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articleManager.getArticles().count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ArticleCell",
            for: indexPath
        ) as? ArticleCell else {
            return UITableViewCell()
        }

        let article = articleManager.getArticles()[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articleManager.getArticles()[indexPath.row]
        let detailVC = DetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "Поделиться") {
            [weak self] (action, view, completionHandler) in
            self?.handleShare(at: indexPath)
            completionHandler(true)
        }
        shareAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [shareAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    private func handleShare(at indexPath: IndexPath) {
        let article = articleManager.getArticles()[indexPath.row]
        guard let url = article.fullArticleUrl else {
            showErrorAlert(message: "Ссылка на статью недоступна для шаринга.")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popoverController = activityVC.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }
        present(activityVC, animated: true)
    }
}
