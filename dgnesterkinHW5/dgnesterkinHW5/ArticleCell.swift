import UIKit

let imageCache = NSCache<NSString, UIImage>()

final class ArticleCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let articleImageView = UIImageView()

    // MARK: Constants

    private enum Constants {
        static let imageSize: CGFloat = 60
        static let sidePadding: CGFloat = 10
        static let topPadding: CGFloat = 10
        static let labelSpacing: CGFloat = 5
        static let descriptionBottomPadding: CGFloat = -10
    }

    // MARK: Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Views

    private func setupViews() {
        contentView.addSubview(articleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)

        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2

        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textColor = .darkGray

        NSLayoutConstraint.activate([
            articleImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            articleImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            articleImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            articleImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.topPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: articleImageView.trailingAnchor,
                constant: Constants.sidePadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.labelSpacing
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: articleImageView.trailingAnchor,
                constant: Constants.sidePadding
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            descriptionLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: Constants.descriptionBottomPadding
            )
        ])
    }

    // MARK: Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.image = nil
        articleImageView.removeShimmerEffect()
    }

    // MARK: Configuration

    func configure(with article: ArticleModel) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description

        articleImageView.image = nil
        articleImageView.addShimmerEffect()

        guard let url = URL(string: article.imageUrl) else {
            articleImageView.removeShimmerEffect()
            return
        }

        let cacheKey = url.absoluteString

        if let cachedImage = imageCache.object(forKey: cacheKey as NSString) {
            DispatchQueue.main.async {
                self.articleImageView.image = cachedImage
                self.articleImageView.removeShimmerEffect()
            }
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: cacheKey as NSString)
                    DispatchQueue.main.async {
                        self.articleImageView.image = image
                        self.articleImageView.removeShimmerEffect()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.articleImageView.removeShimmerEffect()
                    }
                }
            }
        }
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        if let shimmerLayer = articleImageView.layer.sublayers?.first(
            where: { $0.name == "shimmerLayer" }
        ) as? CAGradientLayer {
            shimmerLayer.frame = articleImageView.bounds
        }
    }
}
