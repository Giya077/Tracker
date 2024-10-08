//
//  SelectDaysTableViewCellHelper.swift
//  Tracker
//
//  Created by GiyaDev on 17.05.2024.
//

import Foundation
import UIKit

final class TimetableTableViewCell: UITableViewCell {
    
    var isSelectedDay: Bool = false {
        didSet {
            if switchView.isOn != isSelectedDay {
                switchView.setOn(isSelectedDay, animated: false)
            }
        }
    }
    
    let switchView: UISwitch = {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .systemBlue

        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(switchView)
        backgroundColor = Colors.systemSearchColor
        textLabel?.textColor = .black
        switchView.layer.cornerRadius = 15
        
        NSLayoutConstraint.activate([
                   switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                   switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // Примерное расположение
                   switchView.heightAnchor.constraint(equalToConstant: 31), // Устанавливаем высоту переключателя
                   
                   contentView.bottomAnchor.constraint(greaterThanOrEqualTo: switchView.bottomAnchor, constant: 22) // Растягиваем ячейку до нижней границы switchView с отступом
               ])
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switchView.setOn(false, animated: true)
    }
    
    func configure(dayName: String, isSelected: Bool) {
        textLabel?.text = dayName
        isSelectedDay = isSelected
    }
}
