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
    private var loadingOverlay: LoadingOverlayView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpContens()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.resetPin()
    }

    private func setUpContens() {
        navigationItem.largeTitleDisplayMode = .never
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
    
    func showLoading() {
        
        let overlay = LoadingOverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loadingOverlay = overlay

    }
    
    func stopLoading() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil

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

    func showInfo(_ message: String) {
        infoLabel.text = message
    }

    func clearPin() {
        dotsView.clear()
    }

    func dismiss() {
        dismiss(animated: true)
    }
    func showToastVC(message: String, type: ToastType, completion: (() -> Void)? ) {
        showToast(message: message, type: type)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion?()
        }
        
    }
    func exit() {
        navigationController?.popViewController(animated: true)
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
