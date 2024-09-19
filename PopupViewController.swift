import UIKit

class PopupViewController: UIViewController { // НЕ АКТИВЕН

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onDismiss: (() -> Void)?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        button.addTarget(PopupViewController.self, action: #selector(editTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.addTarget(PopupViewController.self, action: #selector(deleteTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(stackView)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 200),
            stackView.heightAnchor.constraint(equalToConstant: 100)
        ])

        view.backgroundColor = .clear
    }

    @objc private func editTapped() {
        onEdit?()
        dismiss(animated: true, completion: nil)
    }

    @objc private func deleteTapped() {
        onDelete?()
        dismiss(animated: true, completion: nil)
    }
}
