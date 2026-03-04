//
//  SettingsProtocol.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

protocol SettingsPresenterProtocol {
    var currentTheme: AppTheme { get }
    var currentAccent: AppAccent { get }
    var isFaceIdEnabled: Bool { get }
    var compressionLevel: PDFCompressionLevel { get }
    func selectAccent(_ accent: AppAccent)
    func selectTheme(_ theme: AppTheme)
    func toggleFaceId(_ isOn: Bool)
    func openSettings()
    func didClickedResentPin()
    func updateCompresseion(level: PDFCompressionLevel)

}

protocol SettingsViewDelegate: AnyObject {
    func reload()
    func showToastVC(message: String, type: ToastType)
}

protocol SettingsRouterProtocol {
    func openResetPasswordScreen()
}

