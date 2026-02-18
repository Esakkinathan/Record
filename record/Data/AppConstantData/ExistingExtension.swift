//
//  ExistingExtension.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//
import UIKit

extension Date {
    func toString(format: String = "dd-MM-yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        //formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension UIView {
    func add(_ childView: UIView) {
        self.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
    }
    func animateScaleUp() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    func animateScaleDown() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
    
    func addDashedBorder() {
        let border = CAShapeLayer()
        border.strokeColor = AppColor.primaryColor.cgColor
        border.lineWidth = 3
        border.lineDashPattern = [6, 3]
        border.frame = bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: bounds, cornerRadius: 30).cgPath
        layer.addSublayer(border)
    }

}

extension UILabel {
    func labelSetUp() {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textColor = .label
    }
}

extension UIImageView {
    
    func commonSetUp() {
        contentMode = .scaleAspectFit
        clipsToBounds = true
        
    }
    func setAsEmptyDocument() {
        image = DocumentConstantData.docImage
        tintColor = AppColor.emptyDocumentColor
        commonSetUp()
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(view: UIView) {
        self.view.endEditing(true)
    }
    
}
extension String {
    
    func filterForSearch(_ text: String) -> Bool {
        return self.replacingOccurrences(of: " ", with: "").lowercased().contains(text)
    }
    
    func prepareSearchWord() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
