//
//  ExistingExtension.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//
import UIKit

extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension UIView {
    func basicSetUp(for childView: UIView) {
        self.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UILabel {
    func applyWrapping() {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
    }
}
