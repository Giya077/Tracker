import UIKit

// Ячейка типа 1
class CellType1: UICollectionViewCell {
    
    var selectedDays: String? {
        didSet {
            resultLabel.text = selectedDays
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chevronImageView: UIImageView = {
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        return chevronImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBackground()
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(resultLabel)
        contentView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            resultLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            resultLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
            
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupBackground() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    func configure(title: String, days: String?) {
        titleLabel.text = title
        if let daysText = days, !daysText.isEmpty {
            resultLabel.text = daysText
            resultLabel.isHidden = false
        } else {
            resultLabel.text = nil
            resultLabel.isHidden = true
        }
    }
}
