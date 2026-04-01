//
//  SettingsProtocol.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import UIKit

protocol SettingsPresenterProtocol {
    var currentTheme: AppTheme { get }
    var currentAccent: AppAccent { get }
    var isFaceIdEnabled: Bool { get }
    var compressionLevel: PDFCompressionLevel { get }
    func selectAccent(_ accent: AppAccent)
    func selectTheme(_ theme: AppTheme)
    func toggleFaceId(_ isOn: Bool, completion: @escaping (Bool) -> Void)
    func openSettings()
    func didClickedResentPin()
    func updateCompresseion(level: PDFCompressionLevel)
    func numberOfSections() -> Int
    func numberOfRows(section: Int) -> Int
    func sectionRowAt(_ indexPath: IndexPath) -> SettingsItem
    func titleForSection(at section: Int) -> String
    func didClickedRemainderPage()

}

protocol SettingsViewDelegate: AnyObject {
    func reload()
    func showToastVC(message: String, type: ToastType)
}

protocol SettingsRouterProtocol {
    func openResetPasswordScreen()
    func openRemainderScreen()
}

