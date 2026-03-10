//
//  RegistrationFormViewController.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit


class RegistrationFormViewController: UIViewController {
    
    let titleLabel: UILabel = {
       let label = UILabel()
        label.font = AppFont.heading1
        label.textColor = .label
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        return tableView
    }()
    
    var onSave: (() -> Void)?
    
    var presenter: RegistrationFormPresenterProtocol!
    
    let saveButton: AppButton = {
        let button = AppButton(type: .system)
        button.titleLabel?.font = AppFont.heading3
        return button
    }()
    
    let navigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.heading3
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpContents()
        presenter.viewDidLoad()
        
    }
    
    func setUpContents() {
        view.backgroundColor = AppColor.background
        tableView.backgroundColor = AppColor.background

        view.add(titleLabel)
        view.add(tableView)
//        view.add(saveButton)
//        view.add(navigateButton)
        
        tableView.dataSource = self
        
        tableView.register(LoginFormTextField.self, forCellReuseIdentifier: LoginFormTextField.identifier)
        tableView.register(LoginPasswordField.self, forCellReuseIdentifier: LoginPasswordField.myIdentifier)
        tableView.register(Savebutton.self, forCellReuseIdentifier: Savebutton.identifier)
        tableView.register(NavigationButton.self, forCellReuseIdentifier: NavigationButton.identifier)
        
        saveButton.setTitle(presenter.getSaveButtonText(), for: .normal)
        navigateButton.setTitle(presenter.getNavigationButtonText(), for: .normal)
        titleLabel.text = presenter.getTitle()
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        navigateButton.addTarget(self, action: #selector(navigationButtonClicked), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            //saveButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
//            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
//            saveButton.heightAnchor.constraint(equalToConstant: 60),
//            saveButton.bottomAnchor.constraint(equalTo: navigateButton.topAnchor, constant: -50),
            //navigateButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 50),
//            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            navigateButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FormSpacing.height),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FormSpacing.height),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),


        ])

    }
    
    @objc func saveButtonClicked() {
        presenter.saveButtonClicked()
    }
    
    @objc func navigationButtonClicked() {
        presenter.navigationButtonClicked()
    }
    
}

extension RegistrationFormViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfFields()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.field(at: indexPath.row)
        var cell: UITableViewCell
        switch field.type {
        case .text:
            let newCell = tableView.dequeueReusableCell(withIdentifier: LoginFormTextField.identifier, for: indexPath) as! LoginFormTextField
            newCell.configure(title: field.label,placeholder: field.placeholder, image: field.imageName)
            newCell.onValueChange = {
                [weak self] text in
                    return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
            }
            
            newCell.onReturn =  { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row, rules: field.validators)
            if result.isValid {
                _ = newCell.textField.resignFirstResponder()
                if field.gotoNextField{
                    let nextCell = getNextCell(indexPath: indexPath) as! LoginFormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        cell =  newCell
        case .password:
            let newCell = tableView.dequeueReusableCell(withIdentifier: LoginPasswordField.myIdentifier, for: indexPath) as! LoginPasswordField
            newCell.configure(title: field.label, placeholder: field.placeholder)
            newCell.onValueChange = {
                [weak self] text in
                    return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
            }
            
            newCell.onReturn =  { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row, rules: field.validators)
            if result.isValid {
                _ = newCell.textField.resignFirstResponder()
                if field.gotoNextField{
                    let nextCell = getNextCell(indexPath: indexPath) as! LoginFormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        cell =  newCell
        case .button:
            if field.imageName == "save" {
                let newCell = tableView.dequeueReusableCell(withIdentifier: Savebutton.identifier, for: indexPath) as! Savebutton
                newCell.configure(text: field.label)
                newCell.onButtonClicked = { [weak self ] in
                    self?.presenter.saveButtonClicked()
                }
                cell = newCell
            } else {
                let newCell = tableView.dequeueReusableCell(withIdentifier: NavigationButton.identifier, for: indexPath) as! NavigationButton
                newCell.configure(text: field.label)
                newCell.onButtonClicked = { [weak self ] in
                    self?.presenter.navigationButtonClicked()
                }

                cell = newCell
            }
            
        default:
            cell = UITableViewCell()
        }
        
        return cell
        

    }
    func getNextCell(indexPath: IndexPath) -> UITableViewCell? {
        let nextCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section ))
        return nextCell

    }

}

extension RegistrationFormViewController: RegistrationFormViewDelegate {
    func reloadData() {
        saveButton.setTitle(presenter.getSaveButtonText(), for: .normal)
        navigateButton.setTitle(presenter.getNavigationButtonText(), for: .normal)
        titleLabel.text = presenter.getTitle()

        tableView.reloadData()
    }
    
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
    
    func reloadField(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)

    }
    
    func dismiss() {
        //
    }
    
    
}
