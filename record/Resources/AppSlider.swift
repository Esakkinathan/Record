//
//  AppSlider.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//
import UIKit

class AppSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        tintColor = AppColor.primaryColor
        //setThumbImage(makeThumb(color: .systemGreen), for: .normal)
    }
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x,
            y: bounds.midY - 3,
            width: bounds.width,
            height: 6
        )
    }
    private func makeThumb(color: UIColor) -> UIImage {
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(color.cgColor)
        ctx.addEllipse(in: CGRect(origin: .zero, size: size))
        ctx.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }


}
