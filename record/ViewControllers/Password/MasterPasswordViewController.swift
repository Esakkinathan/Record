//
//  MasterPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

class MasterPasswordViewController: UIViewController {

    var presenter: MasterPasswordPresenterProtocol!

    let dotsView = DotsView()
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Enter Pin"
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let keypad = createKeypad()

        let stack = UIStackView(arrangedSubviews: [
            errorLabel,
            dotsView,
            keypad
        ])
        stack.axis = .vertical
        stack.spacing = 40

        view.add(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createKeypad() -> UIStackView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 30

        let numbers = [
            ["1","2","3"],
            ["4","5","6"],
            ["7","8","9"],
            ["","0","⌫"]
        ]

        for row in numbers {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 30
            rowStack.distribution = .equalSpacing
            for item in row {
                if item == "⌫" {
                    let btn = PinButton(number: item)
                    btn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
                    rowStack.addArrangedSubview(btn)
                } else if item.isEmpty {
                    let btn = PinButton(number: "clear")
                    btn.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)
                    rowStack.addArrangedSubview(btn)

                } else {
                    let btn = PinButton(number: item)
                    btn.tag = Int(item)!
                    btn.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
                    rowStack.addArrangedSubview(btn)
                }
            }
            grid.addArrangedSubview(rowStack)
        }
        return grid
    }

    @objc private func numberTapped(_ sender: UIButton) {
        presenter.didTapNumber(sender.tag)
    }

    @objc private func deleteTapped() {
        presenter.didTapDelete()
    }
    @objc private func clearClicked() {
        presenter.didClickClear()
    }
}

extension MasterPasswordViewController: MasterPasswordViewDelegate {

    func updateDots(count: Int) {
        dotsView.update(count: count)
    }

    func showError(_ message: String) {
        errorLabel.text = message
        //errorLabel.isHidden = false
    }

    func clearPin() {
        dotsView.clear()
    }

    func dismiss() {
        dismiss(animated: true)
    }
}
extension MasterPasswordViewController: DocumentNavigationDelegate {
    func push(_ vc: UIViewController) {
        
    }
    
    func presentVC(_ vc: UIViewController) {
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)

    }
    
    
}
