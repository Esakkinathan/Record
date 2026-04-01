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
class TouchAreaButton: UIButton {

    var touchAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerArea = bounds.inset(by: touchAreaInsets)
        return largerArea.contains(point)
    }
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

    private let prevButton: TouchAreaButton = {
        let b = TouchAreaButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        return b
    }()

    private let nextButton: TouchAreaButton = {
        let b = TouchAreaButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        b.tintColor = .label
        return b
    }()

    private let dateButton: AppButton = {
        let b = AppButton()
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.setTitleColor(.label, for: .normal)
        b.configuration?.baseBackgroundColor = .secondarySystemBackground
        b.backgroundColor = .secondarySystemBackground
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


import UIKit

final class DatePickerPopupViewController: UIViewController {

    // MARK: - Public

    var minimumDate: Date?
    var maximumDate: Date?
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    var onDateSelected: ((Date) -> Void)?
    var onCancelled: (() -> Void)?

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        //v.backgroundColor =
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 16
        v.clipsToBounds = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Select Date"
        l.font = .boldSystemFont(ofSize: 17)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .inline
        dp.minimumDate = AppConstantData.minDate
        dp.maximumDate = AppConstantData.maxDate
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Cancel"
        config.baseForegroundColor = .secondaryLabel
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let doneButton: AppButton = {
        //var config = UIButton.Configuration.filled()
        //config.title = "Done"
        //config.baseBackgroundColor =
        //config.baseForegroundColor = .white
        //config.cornerStyle = .medium
        let b = AppButton()
        b.setTitle("Done", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let buttonDivider: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDimmingBackground()
        setupLayout()
        configureInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setupDimmingBackground() {
        view.backgroundColor = .secondarySystemBackground

        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.tag = 999

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dimView.addGestureRecognizer(tap)
        view.addSubview(dimView)
    }

    private func setupLayout() {
        view.addSubview(containerView)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, doneButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(divider)
        containerView.addSubview(datePicker)
        containerView.addSubview(buttonDivider)
        containerView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            // Container: centered, max width 380
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 380),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Divider
            divider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            // Date Picker
            datePicker.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            // Button divider
            buttonDivider.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            buttonDivider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonDivider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonDivider.heightAnchor.constraint(equalToConstant: 0.5),

            // Buttons
            buttonStack.topAnchor.constraint(equalTo: buttonDivider.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
        ])

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    private func configureInitialState() {
        datePicker.date = selectedDate
        if let min = minimumDate { datePicker.minimumDate = min }
        if let max = maximumDate { datePicker.maximumDate = max }

        // Start offscreen for animation
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }

    // MARK: - Animations

    private func animateIn() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.view.backgroundColor = .clear
            if let dim = self.view.viewWithTag(999) {
                dim.alpha = 0
            }
        }, completion: { _ in completion() })
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        let picked = Calendar.current.startOfDay(for: datePicker.date)
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                self?.onDateSelected?(picked)
            }
        }
    }

    @objc private func cancelTapped() {
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                self?.onCancelled?()
            }
        }
    }

    @objc private func backgroundTapped() {
        cancelTapped()
    }
}
