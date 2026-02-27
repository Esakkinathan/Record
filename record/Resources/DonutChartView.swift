//
//  DonutChartView.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//

import UIKit

private extension UIColor {

    /// Card background: white in light, dark elevated surface in dark
    static var cardBackground: UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1)
                : .white
        }
    }

    /// Page background
    static var pageBackground: UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.09, blue: 0.12, alpha: 1)
                : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        }
    }

    /// Primary text (title / count)
    static var primaryText: UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(white: 0.95, alpha: 1)
                : UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1)
        }
    }

    /// Secondary text (segment name labels)
    static var secondaryText: UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(white: 0.70, alpha: 1)
                : UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)
        }
    }

    /// Progress bar track
    static var barTrack: UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(white: 0.25, alpha: 1)
                : UIColor(white: 0.93, alpha: 1)
        }
    }
}

class DonutChartView: UIView {

    var segments: [ChartSegment] = [] {
        didSet { setNeedsDisplay(); updateLegend() }
    }
    var total: Int = 0
    var chartTitle: String = ""

    private let legendStack  = UIStackView()
    private let centerLabel  = UILabel()
    private let centerSub    = UILabel()
    private let titleLabel   = UILabel()
    private let totalLabel   = UILabel()

    private let chartSize: CGFloat   = 160
    private let strokeWidth: CGFloat = 30
    private var donutContainerView: UIView?

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: Setup

    private func setupViews() {
        backgroundColor    = .secondarySystemBackground
        layer.cornerRadius = 20
        applyShadow()

        // Title
        titleLabel.font      = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Subtitle / total
        totalLabel.font      = .systemFont(ofSize: 13, weight: .regular)
        totalLabel.textColor = .secondaryLabel
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalLabel)

        // Horizontal stack: donut | legend
        let hStack       = UIStackView()
        hStack.axis      = .horizontal
        hStack.spacing   = 20
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStack)

        // Donut container (fixed size)
        let donutContainer = UIView()
        donutContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            donutContainer.widthAnchor.constraint(equalToConstant: chartSize),
            donutContainer.heightAnchor.constraint(equalToConstant: chartSize),
        ])

        // Center labels
        centerLabel.font          = .systemFont(ofSize: 24, weight: .bold)
        centerLabel.textColor     = .primaryText
        centerLabel.textAlignment = .center
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        donutContainer.addSubview(centerLabel)

        centerSub.font          = .systemFont(ofSize: 11, weight: .regular)
        centerSub.textColor     = .secondaryLabel
        centerSub.textAlignment = .center
        centerSub.translatesAutoresizingMaskIntoConstraints = false
        donutContainer.addSubview(centerSub)

        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: donutContainer.centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: donutContainer.centerYAnchor, constant: -8),
            centerSub.centerXAnchor.constraint(equalTo: donutContainer.centerXAnchor),
            centerSub.topAnchor.constraint(equalTo: centerLabel.bottomAnchor, constant: 2),
        ])

        // Legend stack
        legendStack.axis      = .vertical
        legendStack.spacing   = 10
        legendStack.alignment = .fill

        hStack.addArrangedSubview(donutContainer)
        hStack.addArrangedSubview(legendStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            totalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            hStack.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])

        self.donutContainerView = donutContainer
    }

    // MARK: Shadow helper (must be re-resolved on trait change)

    private func applyShadow() {
        // In dark mode: stronger/tighter shadow; in light: soft diffused
        let isDark = traitCollection.userInterfaceStyle == .dark
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = isDark ? 0.40 : 0.08
        layer.shadowOffset  = CGSize(width: 0, height: isDark ? 2 : 4)
        layer.shadowRadius  = isDark ? 8 : 16
    }

    // MARK: Trait collection changes

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }

        // CALayer properties are not dynamic — must be updated manually
        backgroundColor = .cardBackground
        applyShadow()

        // Redraw donut (CAShapeLayer strokeColor is not dynamic)
        setNeedsDisplay()

        // Rebuild legend rows (barTrack backgroundColor is static)
        updateLegend()
    }

    // MARK: Draw donut arcs

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let container = donutContainerView, total > 0 else { return }

        // Remove stale shape layers
        container.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }

        let center       = CGPoint(x: chartSize / 2, y: chartSize / 2)
        let radius       = (chartSize / 2) - (strokeWidth / 2) - 4

        // Only draw segments with value > 0
        let activeSegments = segments.filter { $0.value > 0 }
        guard !activeSegments.isEmpty else { return }

        // Gap only makes sense when there are multiple slices
        let gap: CGFloat = activeSegments.count > 1 ? 0.03 : 0.0
        var startAngle: CGFloat = -.pi / 2

        for segment in activeSegments {
            let fraction = CGFloat(segment.value) / CGFloat(total)
            // Ensure arc angle is always positive after subtracting gap
            let arcAngle = max((fraction * 2 * .pi) - gap, 0.001)
            let endAngle = startAngle + arcAngle

            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            let shapeLayer         = CAShapeLayer()
            shapeLayer.path        = path.cgPath
            // Resolve color for current trait environment
            shapeLayer.strokeColor = segment.color.resolvedColor(with: traitCollection).cgColor
            shapeLayer.fillColor   = UIColor.clear.cgColor
            shapeLayer.lineWidth   = strokeWidth
            shapeLayer.lineCap     = .round
            container.layer.addSublayer(shapeLayer)

            // Draw-in animation
            let anim                = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue          = 0
            anim.toValue            = 1
            anim.duration           = 0.8
            anim.timingFunction     = CAMediaTimingFunction(name: .easeInEaseOut)
            shapeLayer.add(anim, forKey: "strokeEnd")

            startAngle += fraction * 2 * .pi
        }

        centerLabel.text = "\(total)"
        centerSub.text   = "total"
        titleLabel.text  = chartTitle
        totalLabel.text  = "Total: \(total)"
    }

    // MARK: Legend

    private func updateLegend() {
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for segment in segments {
            legendStack.addArrangedSubview(makeLegendRow(segment: segment))
        }
    }

    private func makeLegendRow(segment: ChartSegment) -> UIView {
        let container = UIView()

        // Color dot
        let dot                     = UIView()
        dot.backgroundColor         = segment.color
        dot.layer.cornerRadius      = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dot)

        // Name label
        let nameLabel               = UILabel()
        nameLabel.text              = segment.label
        nameLabel.font              = .systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor         = .secondaryText

        // Value label
        let valueLabel              = UILabel()
        valueLabel.text             = "\(segment.value)"
        valueLabel.font             = .systemFont(ofSize: 13, weight: .bold)
        valueLabel.textColor        = .primaryText
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textRow                 = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        textRow.axis                = .horizontal
        textRow.distribution        = .fill
        textRow.spacing             = 6
        textRow.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textRow)

        // Progress bar track — uses dynamic color so it updates automatically
        let barBg                   = UIView()
        barBg.backgroundColor       = .barTrack
        barBg.layer.cornerRadius    = 3
        barBg.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(barBg)

        // Progress bar fill
        let barFill                 = UIView()
        barFill.backgroundColor     = segment.color
        barFill.layer.cornerRadius  = 3
        barFill.translatesAutoresizingMaskIntoConstraints = false
        barBg.addSubview(barFill)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),

            textRow.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            textRow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textRow.topAnchor.constraint(equalTo: container.topAnchor),

            barBg.topAnchor.constraint(equalTo: textRow.bottomAnchor, constant: 4),
            barBg.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            barBg.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            barBg.heightAnchor.constraint(equalToConstant: 5),
            barBg.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
            barFill.heightAnchor.constraint(equalToConstant: 5),
            barFill.widthAnchor.constraint(
                equalTo: barBg.widthAnchor,
                multiplier: CGFloat(segment.value) / CGFloat(max(total, 1))
            ),
        ])

        return container
    }
}
