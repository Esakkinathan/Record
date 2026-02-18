//
//  ListMedicalItemViewCell.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit
class ImageTextView: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //label.setContentCompressionResistancePriority(.required, for: .horizontal)
        setUpContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        add(imageView)
        add(label)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: PaddingSize.content),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

        ])
    }
    
    func configure(text: String ) {
        label.text = text
    }
    func configure(image: String) {
        imageView.image = UIImage(systemName: image)
    }
}
class ListMedicalItemViewCell: UITableViewCell {
    let label1: ImageTextView = {
        let label = ImageTextView()
        label.configure(image: IconName.medicalName)
        return label
    }()
    let label2: ImageTextView = {
        let label = ImageTextView()
        label.configure(image: IconName.instruction)
        return label
    }()
    let label3: ImageTextView = {
        let label = ImageTextView()
        label.configure(image: IconName.dosage)
        return label
    }()
    
    let markLabel: UILabel = {
       let label = UILabel()
        label.text = "Mark As Taken"
        label.textAlignment = .right
        label.font = AppFont.caption
        return label
    }()
    
    let toggle = UISwitch()
    
    var onToggleChanged: ((Bool) -> Void)?
    
    static let identifier = "ListMedicalItemViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContentView() {
        let stack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [label1, label2, label3])
            stack.axis = .vertical
            stack.spacing = PaddingSize.content
            return stack
        }()
        
        //toggle.isOn = false
        selectionStyle = .none
        contentView.add(stack)
        contentView.add(toggle)
        contentView.add(markLabel)
        
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width * 3),
            
            stack.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -PaddingSize.width),
            
            markLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 2),
            markLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 3),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    @objc func toggleChanged() {
        onToggleChanged?(toggle.isOn)
    }
    
    func configure(text1: String, text2: String, text3: String, canShow: Bool, state: Bool) {
        label1.configure(text: text1)
        label2.configure(text: text2)
        label3.configure(text: text3)
        markLabel.isHidden = !canShow
        toggle.isHidden = !canShow
        toggle.setOn(state, animated: false)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        toggle.isHidden = false
        markLabel.isHidden = false
        onToggleChanged = nil
    }
}
