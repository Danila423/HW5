import UIKit

extension UIView {
    // MARK: Shimmer Effect

    func addShimmerEffect() {
        if layer.sublayers?.contains(where: { $0.name == Constants.ShimmerLayerName }) == true {
            return
        }

        let shimmerLayer = CAGradientLayer()
        shimmerLayer.name = Constants.ShimmerLayerName
        shimmerLayer.colors = [
            Constants.ShimmerColor.withAlphaComponent(Constants.ShimmerAlphaHigh).cgColor,
            Constants.ShimmerColor.withAlphaComponent(Constants.ShimmerAlphaLow).cgColor,
            Constants.ShimmerColor.withAlphaComponent(Constants.ShimmerAlphaHigh).cgColor
        ]
        shimmerLayer.locations = Constants.ShimmerLocations
        shimmerLayer.startPoint = Constants.ShimmerStartPoint
        shimmerLayer.endPoint = Constants.ShimmerEndPoint
        shimmerLayer.frame = self.bounds

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = Constants.ShimmerAnimationFrom
        animation.toValue = Constants.ShimmerAnimationTo
        animation.duration = Constants.ShimmerAnimationDuration
        animation.repeatCount = .infinity

        shimmerLayer.add(animation, forKey: Constants.ShimmerAnimationKey)
        self.layer.addSublayer(shimmerLayer)
    }

    func removeShimmerEffect() {
        if let shimmerLayer = layer.sublayers?.first(where: { $0.name == Constants.ShimmerLayerName }) {
            shimmerLayer.removeAllAnimations()
            shimmerLayer.removeFromSuperlayer()
        }
    }

    // MARK: - Constants

    private enum Constants {
        static let ShimmerLayerName = "shimmerLayer"
        static let ShimmerColor = UIColor.lightGray
        static let ShimmerAlphaHigh: CGFloat = 0.6
        static let ShimmerAlphaLow: CGFloat = 0.2
        static let ShimmerLocations: [NSNumber] = [0.0, 0.5, 1.0]
        static let ShimmerStartPoint = CGPoint(x: 0.0, y: 0.5)
        static let ShimmerEndPoint = CGPoint(x: 1.0, y: 0.5)
        static let ShimmerAnimationFrom: [NSNumber] = [-1.0, -0.5, 0.0]
        static let ShimmerAnimationTo: [NSNumber] = [1.0, 1.5, 2.0]
        static let ShimmerAnimationDuration: CFTimeInterval = 1.5
        static let ShimmerAnimationKey = "shimmerAnimation"
    }
}
