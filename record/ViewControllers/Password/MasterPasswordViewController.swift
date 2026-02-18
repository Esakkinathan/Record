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
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        //label.text = "Enter Pin"
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpContens()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.resetPin()
    }

    private func setUpContens() {
        title = "Password Manager"
        view.backgroundColor = .systemBackground
        
        let keypad = createKeypad()

        let stack = UIStackView(arrangedSubviews: [
            infoLabel,
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
        presenter.resetPin()
    }
}

extension MasterPasswordViewController: MasterPasswordViewDelegate {

    func updateDots(count: Int) {
        dotsView.update(count: count)
    }

    func showInfo(_ message: String) {
        infoLabel.text = message
    }

    func clearPin() {
        dotsView.clear()
    }

    func dismiss() {
        dismiss(animated: true)
    }
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
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
