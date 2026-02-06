//
//  DocumentThumbnailProvider.swift
//  record
//
//  Created by Esakkinathan B on 23/01/26.
//

import QuickLookThumbnailing
import UIKit
final class DocumentThumbnailProvider {
    
    static func generate(
        for url: String,
        size: CGSize = CGSize(width: 80, height: 80),
        scale providedScale: CGFloat? = nil,
        completion: @escaping (UIImage?) -> Void
    ) {
        let fileUrl = URL(fileURLWithPath: url)
        let scale: CGFloat
        if let providedScale {
            scale = providedScale
        } else {
            if #available(iOS 26.0, *) {
                scale = UITraitCollection.current.displayScale
            } else {
                scale = UIScreen.main.scale
            }
        }

        let request = QLThumbnailGenerator.Request(
            fileAt: fileUrl,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, _ in
            DispatchQueue.main.async {
                completion(thumbnail?.uiImage)
            }
        }
    }
}
