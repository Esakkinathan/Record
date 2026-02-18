//
//  DateNavigator.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit



protocol DateNavigatorViewDelegate: AnyObject {
    func dateNavigator(_ navigator: DateNavigatorView, didChange date: Date)
    func dateNavigatorRequestedPicker(_ navigator: DateNavigatorView, current: Date)
}

final class DateNavigatorView: UIView {


    weak var delegate: DateNavigatorViewDelegate?

    var minimumDate: Date? {
        didSet { validateCurrentDate() }
    }

    var maximumDate: Date? {
        didSet { validateCurrentDate() }
    }

    private(set) var currentDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            updateLabel()
        }
    }

    func setDate(_ date: Date) {
        let normalized = Calendar.current.startOfDay(for: date)
        let valid = clampedDate(normalized)

        guard valid != currentDate else { return }

        currentDate = valid
        delegate?.dateNavigator(self, didChange: valid)
    }

    private let prevButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        return b
    }()

    private let nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        b.tintColor = .label
        return b
    }()

    private let dateButton: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.setTitleColor(.label, for: .normal)
        return b
    }()

    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }


    private func setup() {

        let stack = UIStackView(arrangedSubviews: [
            prevButton,
            dateButton,
            nextButton
        ])

        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 8

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 36)
        ])

        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(dateTapped), for: .touchUpInside)

        updateLabel()
    }


    @objc private func prevTapped() {
        changeDate(by: -1)
    }

    @objc private func nextTapped() {
        changeDate(by: 1)
    }

    @objc private func dateTapped() {
        delegate?.dateNavigatorRequestedPicker(self, current: currentDate)
    }

    private func changeDate(by days: Int) {

        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) else { return }

        let valid = clampedDate(newDate)
        guard valid != currentDate else { return }

        currentDate = valid
        delegate?.dateNavigator(self, didChange: valid)
    }


    private func clampedDate(_ date: Date) -> Date {

        if let min = minimumDate {
            let m = Calendar.current.startOfDay(for: min)
            if date < m { return m }
        }

        if let max = maximumDate {
            let m = Calendar.current.startOfDay(for: max)
            if date > m { return m }
        }

        return date
    }

    private func validateCurrentDate() {
        currentDate = clampedDate(currentDate)
    }


    private func updateLabel() {
        dateButton.setTitle(formatter.string(from: currentDate), for: .normal)
        updateButtons()
    }

    private func updateButtons() {

        if let min = minimumDate {
            prevButton.isEnabled = currentDate > Calendar.current.startOfDay(for: min)
        } else {
            prevButton.isEnabled = true
        }

        if let max = maximumDate {
            nextButton.isEnabled = currentDate < Calendar.current.startOfDay(for: max)
        } else {
            nextButton.isEnabled = true
        }

        prevButton.alpha = prevButton.isEnabled ? 1 : 0.3
        nextButton.alpha = nextButton.isEnabled ? 1 : 0.3
    }
}
