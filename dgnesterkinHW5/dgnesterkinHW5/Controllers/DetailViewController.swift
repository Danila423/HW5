import UIKit

final class DetailViewController: UIViewController {

    private let article: ArticleModel
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: Constants

    private enum Constants {
        static let topPadding: CGFloat = 16
        static let sidePadding: CGFloat = 16
        static let imageHeight: CGFloat = 300
        static let titleBottomSpacing: CGFloat = 16
        static let textTopSpacing: CGFloat = 12
        static let textBottomPadding: CGFloat = -16
    }

    // MARK: Initialization

    init(article: ArticleModel) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Детали новости"
        setupUI()
        configureWithArticle()
    }

    // MARK: Setup UI

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.topPadding
            ),
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            imageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),

            titleLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: Constants.titleBottomSpacing
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),

            textLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.textTopSpacing
            ),
            textLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.textBottomPadding
            )
        ])
    }

    // MARK: Configuration

    private func configureWithArticle() {
        titleLabel.text = article.title
        if let fullText = article.fullText, !fullText.isEmpty {
            textLabel.text = fullText
        } else {
            textLabel.text = article.description
        }

        imageView.image = nil
        if let url = URL(string: article.imageUrl) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}
