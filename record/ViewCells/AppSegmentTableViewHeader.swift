//
//  AppSegmentTableViewHeader.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

class AppSegmentTableViewHeader: UITableViewHeaderFooterView {
    static let identifier = "AppSegmentTableViewHeader"

    let segmentBar = AppSegmentBar(items: MedicalKind.allCases.map{ "\($0.rawValue)"})

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.font = AppFont.heading3
        label.textColor = .secondaryLabel
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 1
        button.setImage(UIImage(systemName: IconName.add), for: .normal)
        button.configuration = AppConstantData.buttonConfiguration
        return button
    }()

    var onAddButtonClicked: (() -> Void)?
    var onSegmentChange: ((Int) -> Void)?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
    }


    func setupContentView() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.add(segmentBar)
        contentView.add(titleLabel)
        contentView.add(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        
        segmentBar.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        
        NSLayoutConstraint.activate([
            segmentBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            segmentBar.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -PaddingSize.height),
            segmentBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            segmentBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            
            titleLabel.topAnchor.constraint(equalTo: segmentBar.bottomAnchor, constant: PaddingSize.height),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: PaddingSize.height),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -PaddingSize.height ),
            addButton.topAnchor.constraint(equalTo: segmentBar.bottomAnchor, constant: PaddingSize.height),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            //addButton.widthAnchor.constraint(equalToConstant: 100)
        ])

    }
    
    func configure(title: String, selectedSegment: Int) {
        titleLabel.text = title
        segmentBar.selectedSegmentIndex = selectedSegment
    }
    
    @objc func segmentChanged(){
        onSegmentChange?(segmentBar.selectedSegmentIndex)
    }
    
    @objc private func addButtonClicked() {
        onAddButtonClicked?()
    }
}
