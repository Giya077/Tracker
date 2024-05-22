import UIKit

// Ячейка типа 1
class CellType1: UICollectionViewCell {
    
    var selectedDays: String? {
        didSet {
            daysLabel.text = selectedDays
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let daysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBackground()
    }
    
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
             titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             
             daysLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
             daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             daysLabel.heightAnchor.constraint(equalToConstant: 20), // Примерная высота daysLabel
             daysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
             daysLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
         ])
    }
    
    private func setupBackground() {
        contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    func configure(title: String, days: String?) {
        titleLabel.text = title
        if let daysText = days, !daysText.isEmpty {
            daysLabel.text = daysText
            daysLabel.isHidden = false
        } else {
            daysLabel.text = nil
            daysLabel.isHidden = true
        }
    }
 }
