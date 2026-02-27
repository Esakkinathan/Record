//
//  FormFieldViewController.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import UIKit
import VTDB
import Vision
import VisionKit
internal import UniformTypeIdentifiers
import QuickLook
import PhotosUI

class LoadingOverlayView: UIView {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(backgroundView)
        addSubview(spinner)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
class FormFieldViewController: KeyboardNotificationViewController {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        return tableView
    }()
    let spinner = UIActivityIndicatorView(style: .large)
    var presenter: FormFieldPresenterProtocol!
    var onAdd: ((Persistable) -> Void)?
    var onEdit: ((Persistable) -> Void)?
    var previewUrl: URL?
    private var loadingOverlay: LoadingOverlayView?
    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
        hideKeyboardWhenTappedAround()
    }

    func setUpContents() {
        
        view.backgroundColor = AppColor.background

        view.add(tableView)
        presentationController?.delegate = self
        tableView.dataSource = self
        
        spinner.center = view.center
        view.addSubview(spinner)

        tableView.register(FormSelectField.self, forCellReuseIdentifier: FormSelectField.identifier)
        tableView.register(FormTextField.self, forCellReuseIdentifier: FormTextField.identifier)
        tableView.register(FormDateField.self, forCellReuseIdentifier: FormDateField.identifier)
        tableView.register(FormFileUpload.self, forCellReuseIdentifier: FormFileUpload.identifier)
        tableView.register(FormTextView.self, forCellReuseIdentifier: FormTextView.identifier)
        tableView.register(FormPasswordField.self, forCellReuseIdentifier: FormPasswordField.myidentifier)
        tableView.register(FormTextFieldSelectField.self, forCellReuseIdentifier: FormTextFieldSelectField.identifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.cancel), style: AppConstantData.buttonStyle, target: self, action: #selector(cancelClicked))
        navigationItem .rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.checkmark), style: AppConstantData.buttonStyle, target: self, action: #selector(saveClicked))
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
    
    @objc func cancelClicked() {
        presenter.cancelClicked()
    }
    
    func showExitAlert() {
        let alert = UIAlertController(
            title: "Discard Changes?",
            message: "Are you sure you want to exit?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.presenter.exitScreen()
        })
        
        present(alert, animated: true)
    }
    
    @objc func saveClicked() {
        view.endEditing(true)
        presenter.saveClicked()
    }
    
//    func openScanner() {
//        guard VNDocumentCameraViewController.isSupported else {
//            print("Scanner not supported")
//            return
//        }
//
//        let scanner = VNDocumentCameraViewController()
//        scanner.delegate = self
//        present(scanner, animated: true)
//    }

}

extension FormFieldViewController: VNDocumentCameraViewControllerDelegate {

    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        controller.dismiss(animated: true)

        var images: [UIImage] = []

        for i in 0..<min(scan.pageCount, 10) {
            images.append(scan.imageOfPage(at: i))
        }
        presenter.processImages(from: images)
    }

    func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        
        controller.dismiss(animated: true)
    }
}

extension FormFieldViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            return previewUrl! as QLPreviewItem
    }

}

extension FormFieldViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfFields()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.field(at: indexPath.row)
        var cell: UITableViewCell
        switch field.type {
        case .text:
            cell = textFieldCell(indexPath, field)
        case .password:
            cell = passwordFieldCell(indexPath, field)
        case .date:
            cell = dateFieldCell(indexPath, field)
        case .select:
            cell = selectCell(indexPath, field)
        case .textSelect:
            cell = textSelectCell(indexPath, field)
        case .textView:
            cell = textViewCell(indexPath,field)
        case .fileUpload:
            cell = fileUploadCell(indexPath, field)
        case .button:
            cell = buttonViewCell(indexPath, field)
        }
        return cell
    }
}

extension FormFieldViewController: FormFieldViewDelegate {
    
    func showYesNoAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Scan", message: "Do you want to scan and automatically fetch data?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }

    
    func showError(_ message: String?) {
        if let msg = message {
            showToast(message: msg, type: .error)
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func reloadField(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func configureToOpenDocument(previewUrl: URL) {
        self.previewUrl  = previewUrl
    }
    func showToastVc(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
}

extension FormFieldViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else {
            return
        }
        guard urls.count <= PDFMergeError.maxFiles else {
            showError("Maximum of \(PDFMergeError.maxFiles) allowed")
            return
        }
        presenter.didPickDocuments(urls: urls)
    }
}

extension FormFieldViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}
extension FormFieldViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else { return }
        
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            let provider = result.itemProvider
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                
                dispatchGroup.enter()
                
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    if let img = image as? UIImage {
                        images.append(img)
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.presenter?.processImages(from: images)
        }
    }
}
extension FormFieldViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            presenter.saveImage(image)
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension FormFieldViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
//extension FormFieldViewController: FormTextFieldDelegate {
//    
//}

extension FormFieldViewController {
    
    
    func isFieldRequired(field: FormField) -> Bool{
        return field.validators.contains(.required)
    }
    
    func getMaxValue(rules: [ValidationRules]) -> Int {
        for rule in rules {
            switch rule {
            case .maxLength(let value):
                return value
            case .exactLength(let value):
                return value
            default:
                continue
            }
        }
        return 30
    }

    
    func configureCell(cell: FormTextField,field: FormField, indexPath: IndexPath) -> FormTextField {
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, isRequired: isFieldRequired(field: field),  maxCount: getMaxValue(rules: field.validators))
        cell.textField.returnKeyType = field.returnType ?? .default
        cell.textField.keyboardType = field.keyboardMode ?? .alphabet
        //cell.delegate = self
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        cell.showErrorOnLengthExceeds = { [weak self] msg in
            self?.showToastVc(message: msg, type: .warning)
        }
        
        return cell

    }

    
    
    func textFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormTextField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
        
        cell = configureCell(cell: cell, field: field, indexPath: indexPath)
        
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row, rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
                if field.gotoNextField{
                    let nextCell = getNextCell(indexPath: indexPath) as! FormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        return cell
    }
    
    func passwordFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormPasswordField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormPasswordField.myidentifier, for: indexPath) as! FormPasswordField
        
        cell = configureCell(cell: cell, field: field, indexPath: indexPath) as! FormPasswordField
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
                if field.gotoNextField {
                    let nextCell = getNextCell(indexPath: indexPath) as! FormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        
        return cell
    }

    func dateFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormDateField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormDateField.identifier, for: indexPath) as! FormDateField
        
        cell.configure(title: field.label, date: field.value as? Date,isRequired: isFieldRequired(field: field))
        
        cell.onValueChange = { [weak self] date in
            self?.presenter.updateValue(date, at: indexPath.row)
            return nil
        }
        return cell

    }
    
    
    
    func getNextCell(indexPath: IndexPath) -> UITableViewCell? {
        let nextCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section ))
        return nextCell

    }
    
    func selectCell(_ indexPath: IndexPath, _ field: FormField) -> FormSelectField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
        cell.configure(title: field.label, text: field.value as? String, isRequired: isFieldRequired(field: field))
        cell.onSelectClicked = { [weak self] in
            self?.presenter.selectClicked(at: indexPath.row)
        }
        return cell
    }
    
    func textSelectCell(_ indexPath: IndexPath, _ field: FormField) -> FormTextFieldSelectField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldSelectField.identifier, for: indexPath) as! FormTextFieldSelectField
        
        cell.textField.returnKeyType = field.returnType ?? .default
        cell.textField.keyboardType = field.keyboardMode ?? .alphabet
        
        let selectValue = presenter.field(at: indexPath.row+1).value as? String ?? ""
        
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder,selectedValue: selectValue, isRequired: isFieldRequired(field: field))
        
        cell.onTextValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
            }
            return result.errorMessage
        }
        
        cell.onSelectClicked = { [weak self] in
            self?.presenter.selectClicked(at: indexPath.row)
        }
        
        return cell

    }
     
    func fileUploadCell(_ indexPath: IndexPath, _ field: FormField) -> FormFileUpload {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFileUpload.identifier, for: indexPath) as! FormFileUpload
        
        cell.configure(title: field.label, filePath: field.value as? String, isRequired: isFieldRequired(field: field))
        
        cell.onUploadDocument = { [weak self] type in
            self?.presenter.uploadDocument(at: indexPath.row, type: type)
        }
        cell.onViewDocument = { [weak self] in
            self?.presenter.viewDocument(at: indexPath.row)
        }
        cell.onRemoveDocument = { [weak self] in
            self?.presenter.removeDocument(at: indexPath.row)
        }
        cell.onOpenCamera = { [weak self] in
            self?.presenter.openCameraClicked()
        }
        return cell
    }
    
    func textViewCell(_ indexPath: IndexPath,_ field: FormField) -> FormTextView {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextView.identifier, for: indexPath) as! FormTextView
        cell.configure(title: field.label, text: field.value as? String, isRequired: isFieldRequired(field: field))
        cell.textView.keyboardType = .default
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row, rules: field.validators).errorMessage
        }
        return cell
    }
    
    func buttonViewCell(_ indexPath: IndexPath, _ field: FormField) -> ButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as! ButtonTableViewCell
        cell.configure(title: field.label)
        cell.onButtonClicked = { [weak self] in
            self?.presenter.formButtonClicked()
        }
        return cell
    }

}
