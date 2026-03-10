//
//  InfoCardView.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import UIKit


struct MedicineDetail {
    let medicineName: String   // Medicine.name  e.g. "Paracetamol"
    let medicalTitle: String
    let kind: MedicalKind
}

struct ScheduleRowViewModel {
    let schedule: MedicalSchedule
    let completed: [MedicineDetail]
    let remaining: [MedicineDetail]

    var completedCount: Int { completed.count }
    var remainingCount: Int { remaining.count }
}

struct DashboardViewModel {
    let scheduleRows: [ScheduleRowViewModel]
}

class InfoCardView: UIView {

    // Callback: (tapped row view, schedule row data, tapped segment: .completed | .remaining)
    var onBadgeTapped: ((ScheduleRowViewModel, BadgeSegment) -> Void)?

    enum BadgeSegment { case completed, remaining }

    private let headerStack  = UIStackView()
    private let iconView     = UIImageView()
    private let titleLabel   = UILabel()
    private let subtitleLabel = UILabel()
    private let rowsStack    = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }



    private func setupUI() {
        backgroundColor       = .secondarySystemBackground
        layer.cornerRadius    = 20
        layer.cornerCurve     = .continuous
        //layer.shadowColor     = UIColor.black.cgColor
        //layer.shadowOpacity   = 0.07
        //layer.shadowOffset    = CGSize(width: 0, height: 6)
        //layer.shadowRadius    = 16

        iconView.contentMode  = .scaleAspectFit
        iconView.tintColor    = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHidden     = true
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
        ])

        titleLabel.font       = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor  = .label

        subtitleLabel.font    = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.isHidden  = true

        let titleColumn = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleColumn.axis    = .vertical
        titleColumn.spacing = 2

        headerStack.axis        = .horizontal
        headerStack.alignment   = .center
        headerStack.spacing     = 10
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleColumn)

        rowsStack.axis    = .vertical
        rowsStack.spacing = 0

        let root = UIStackView(arrangedSubviews: [headerStack, makeDivider(), rowsStack])
        root.axis    = .vertical
        root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false

        addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: topAnchor,       constant:  20),
            root.leadingAnchor.constraint(equalTo: leadingAnchor,   constant:  20),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: bottomAnchor,    constant: -20),
        ])
    }


    // MARK: Configure

    func configure(
        dashboard: DashboardViewModel,
        title: String       = "Today's Overview",
        icon: UIImage?      = nil,
        subtitle: String?   = nil,
        iconTint: UIColor   = .systemBlue
    ) {
        titleLabel.text = title

        if let icon {
            iconView.image    = icon
            iconView.tintColor = iconTint
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        if let subtitle {
            subtitleLabel.text    = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }

        rebuildRows(dashboard.scheduleRows)
    }


    // MARK: Row building

    private func rebuildRows(_ rows: [ScheduleRowViewModel]) {
        rowsStack.arrangedSubviews.forEach {
            rowsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, row) in rows.enumerated() {
            let rowView = makeScheduleRow(for: row)
            rowsStack.addArrangedSubview(rowView)

            if index < rows.count - 1 {
                let divider = makeDivider()
                rowsStack.addArrangedSubview(divider)
                rowsStack.setCustomSpacing(12, after: rowView)
                rowsStack.setCustomSpacing(12, after: divider)
            }
        }
    }

    /// One full row:  [Schedule label]  ·  [✓ N done]  [⚠ N left]
    private func makeScheduleRow(for model: ScheduleRowViewModel) -> UIView {
        let scheduleLabel           = UILabel()
        scheduleLabel.text          = model.schedule.rawValue
        scheduleLabel.font          = .systemFont(ofSize: 15, weight: .medium)
        scheduleLabel.textColor     = .secondaryLabel
        scheduleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        scheduleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Completed badge
        let completedBadge = makeBadge(
            text:    completedLabel(model.completedCount),
            style:   model.completedCount > 0 ? .success : .normal,
            segment: .completed,
            rowModel: model
        )

        // Remaining badge
        let remainingBadge = makeBadge(
            text:    remainingLabel(model.remainingCount),
            style:   model.remainingCount == 0 ? .success : .danger,
            segment: .remaining,
            rowModel: model
        )

        let badgeStack       = UIStackView(arrangedSubviews: [completedBadge, remainingBadge])
        badgeStack.axis      = .horizontal
        badgeStack.spacing   = 6
        badgeStack.alignment = .center

        let rowStack         = UIStackView(arrangedSubviews: [scheduleLabel, badgeStack])
        rowStack.axis        = .horizontal
        rowStack.alignment   = .center
        rowStack.spacing     = 8
        rowStack.distribution = .fill

        return rowStack
    }

    private func completedLabel(_ count: Int) -> String {
        count == 0 ? "0 done" : "\(count) done"
    }

    private func remainingLabel(_ count: Int) -> String {
        count == 0 ? "All done ✓" : "\(count) remaining"
    }


    // MARK: Badge factory

    private func makeBadge(
        text: String,
        style: InfoRowModel.Style,
        segment: BadgeSegment,
        rowModel: ScheduleRowViewModel
    ) -> UIView {
        let colors = badgeColors(for: style)

        let label           = UILabel()
        label.text          = text
        label.font          = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor     = colors.text
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        let pill            = BadgePillView()          // subclass that stores context
        pill.backgroundColor  = colors.background
        pill.layer.cornerRadius = 10
        pill.layer.cornerCurve  = .continuous
        pill.rowModel  = rowModel
        pill.segment   = segment

        pill.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor,       constant:  4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor,   constant:  10),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -10),
        ])

        // Tap recogniser
        let tap = UITapGestureRecognizer(target: self, action: #selector(badgeTapped(_:)))
        pill.addGestureRecognizer(tap)
        pill.isUserInteractionEnabled = true

        return pill
    }

    @objc private func badgeTapped(_ sender: UITapGestureRecognizer) {
        guard
            let pill = sender.view as? BadgePillView,
            let model = pill.rowModel,
            let segment = pill.segment
        else { return }

        // Skip tapping if list is empty
        let list = segment == .completed ? model.completed : model.remaining
        guard !list.isEmpty else { return }

        animatePillPress(pill)
        onBadgeTapped?(model, segment)
    }

    private func animatePillPress(_ view: UIView) {
        UIView.animate(
            withDuration: 0.1,
            animations: { view.transform = CGAffineTransform(scaleX: 0.93, y: 0.93) },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.5
                ) { view.transform = .identity }
            }
        )
    }


    // MARK: Helpers

    private func badgeColors(for style: InfoRowModel.Style) -> (text: UIColor, background: UIColor) {
        switch style {
        case .normal:  return (.secondaryLabel, .tertiarySystemFill)
        case .success: return (.systemGreen,    .systemGreen.withAlphaComponent(0.12))
        case .warning: return (.systemOrange,   .systemOrange.withAlphaComponent(0.12))
        case .danger:  return (.systemRed,      .systemRed.withAlphaComponent(0.12))
        }
    }

    private func makeDivider() -> UIView {
        let line            = UIView()
        line.backgroundColor = .separator.withAlphaComponent(0.5)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return line
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(down: true)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(down: false)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(down: false)
    }

    private func animatePress(down: Bool) {
        UIView.animate(
            withDuration: down ? 0.12 : 0.25,
            delay: 0,
            usingSpringWithDamping: down ? 1 : 0.6,
            initialSpringVelocity: down ? 0 : 0.5
        ) {
            self.transform         = down ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.layer.shadowOpacity = down ? 0.03 : 0.07
        }
    }
}

private class BadgePillView: UIView {
    var rowModel: ScheduleRowViewModel?
    var segment: InfoCardView.BadgeSegment?
}


class MedicinePopupViewController: UIViewController {

    // MARK: Input
    private let scheduleName: String
    private let segment: InfoCardView.BadgeSegment
    private let medicines: [MedicineDetail]

    init(scheduleName: String, segment: InfoCardView.BadgeSegment, medicines: [MedicineDetail]) {
        self.scheduleName = scheduleName
        self.segment      = segment
        self.medicines    = medicines
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle   = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError() }


    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        let card = buildCard()
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])

        // Tap outside to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)

        // Entry animation
        card.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        card.alpha     = 0
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            card.transform = .identity
            card.alpha     = 1
        }
    }

    @objc private func dismiss(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    private func buildCard() -> UIView {
        let card              = UIView()
        card.backgroundColor  = .secondarySystemBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve  = .continuous

        // Header
        let stateText = segment == .completed ? "Completed" : "Remaining"

        let titleLabel           = UILabel()
        titleLabel.text          = "\(scheduleName) · \(stateText)"
        titleLabel.font          = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor     = .label

        let countLabel           = UILabel()
        countLabel.text          = "\(medicines.count) medicine\(medicines.count == 1 ? "" : "s")"
        countLabel.font          = .systemFont(ofSize: 13, weight: .regular)
        countLabel.textColor     = .tertiaryLabel

        let headerCol            = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        headerCol.axis           = .vertical
        headerCol.spacing        = 2

        let closeButton          = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor    = .tertiaryLabel
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let header               = UIStackView(arrangedSubviews: [headerCol, closeButton])
        header.axis              = .horizontal
        header.alignment         = .center
        header.distribution      = .equalSpacing
        // Medicine list
        let listStack            = UIStackView()
        listStack.axis           = .vertical
        listStack.spacing        = 0

        for (index, medicine) in medicines.enumerated() {
            let row = makeMedicineRow(medicine, index: index)
            listStack.addArrangedSubview(row)

            if index < medicines.count - 1 {
                let div              = UIView()
                div.backgroundColor  = .separator.withAlphaComponent(0.4)
                div.translatesAutoresizingMaskIntoConstraints = false
                div.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                listStack.addArrangedSubview(div)
                listStack.setCustomSpacing(10, after: row)
                listStack.setCustomSpacing(10, after: div)
            }
        }

        // Root stack
        let divider              = UIView()
        divider.backgroundColor  = .separator.withAlphaComponent(0.5)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        let root                 = UIStackView(arrangedSubviews: [header, divider, listStack])
        root.axis                = .vertical
        root.spacing             = 14
        root.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: card.topAnchor,       constant:  20),
            root.leadingAnchor.constraint(equalTo: card.leadingAnchor,   constant:  20),
            root.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: card.bottomAnchor,    constant: -20),
        ])

        return card
    }

    private func makeMedicineRow(_ detail: MedicineDetail, index: Int) -> UIView {
        // Circle index badge
//        let indexLabel           = UILabel()
//        indexLabel.text          = "\(index + 1)"
//        indexLabel.font          = .systemFont(ofSize: 12, weight: .semibold)
//        indexLabel.textColor     = .white
//        indexLabel.textAlignment = .center
//
//        let circle               = UIView()
//        circle.backgroundColor   = segment == .completed ? .systemGreen : .systemRed
//        circle.layer.cornerRadius = 12
//        circle.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            circle.widthAnchor.constraint(equalToConstant: 24),
//            circle.heightAnchor.constraint(equalToConstant: 24),
//        ])
//        circle.addSubview(indexLabel)
//        indexLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            indexLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
//            indexLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
//        ])
        
        let iconView: UIImageView = {
            let view = UIImageView(image: UIImage(systemName:detail.kind.image))
            view.contentMode = .scaleAspectFit
            view.tintColor = segment == .completed ? .systemGreen : .systemRed
            view.heightAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize).isActive = true
            view.widthAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize).isActive = true
            return view
        }()
        
        // Medicine name + reason
        let nameLabel            = UILabel()
        nameLabel.text           = detail.medicineName
        nameLabel.font           = AppFont.body
        nameLabel.textColor      = .label

        let reasonLabel          = UILabel()
        reasonLabel.text         = "For \(detail.medicalTitle)"
        reasonLabel.font         = AppFont.small
        reasonLabel.textColor    = .secondaryLabel

        let textStack            = UIStackView(arrangedSubviews: [nameLabel, reasonLabel])
        textStack.axis           = .vertical
        textStack.spacing        = 2

        let row                  = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis                 = .horizontal
        row.alignment            = .center
        row.distribution = .fillProportionally
        row.spacing              = 12

        return row
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension MedicinePopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // Only dismiss when touching the dim background, not the card
        return touch.view == self.view
    }
}


// MARK: - Usage in your ViewController
/*

class TodayViewController: UIViewController {

    private let card = InfoCardView()
    private let useCase = ActiveMedicineUseCase()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout card ...
        view.addSubview(card)
        // ... your constraints here ...

        // Wire up the popup callback
        card.onBadgeTapped = { [weak self] rowModel, segment in
            guard let self else { return }
            let medicines = segment == .completed ? rowModel.completed : rowModel.remaining
            let popup = MedicinePopupViewController(
                scheduleName: rowModel.schedule.rawValue,
                segment: segment,
                medicines: medicines
            )
            self.present(popup, animated: true)
        }

        loadDashboard()
    }

    private func loadDashboard() {
        // Pass your Medical array here
        let medicals: [Medical] = /* fetch from your repo */
        let dashboard = useCase.execute(medicals: medicals)
        card.configure(
            dashboard: dashboard,
            title: "Today's Overview",
            icon: UIImage(systemName: "cross.case.fill"),
            subtitle: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
            iconTint: .systemBlue
        )
    }
}
*/
