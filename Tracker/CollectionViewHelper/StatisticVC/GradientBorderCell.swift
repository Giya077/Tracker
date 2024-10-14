import UIKit

final class GradientBorderCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
        setupLabels()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        // Настройка titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = UIColor.label
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.numberOfLines = 1
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupGradientBorder() {
        let borderThickness: CGFloat = 1.0
        let cornerRadius: CGFloat = 16.0
        
        gradientLayer.colors = [ColorResource.sfCaesarPurple, ColorResource.sfChampagne, ColorResource.sfDarkPurple] //TODO
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.masksToBounds = true
        
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderThickness, dy: borderThickness), cornerRadius: cornerRadius)
        path.append(innerPath.reversing())
        maskLayer.path = path.cgPath
        gradientLayer.mask = maskLayer
        
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
