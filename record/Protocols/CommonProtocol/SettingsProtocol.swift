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
    func selectAccent(_ accent: AppAccent)
    func selectTheme(_ theme: AppTheme)
    func toggleFaceId(_ isOn: Bool)

}

protocol SettingsViewDelegate: AnyObject {
    func reload()
}
