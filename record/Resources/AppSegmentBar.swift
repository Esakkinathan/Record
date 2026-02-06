//
//  AppSegmentBar.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//
import UIKit

class AppSegmentBar: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.shadowColor = AppColor.primaryColor.cgColor
        tintColor = AppColor.primaryColor
        selectedSegmentTintColor = AppColor.primaryColor
    }
    
}
