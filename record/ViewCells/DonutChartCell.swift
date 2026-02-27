//
//  DonutChartCell.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

class DonutChartCell: UITableViewCell {
    static let identifier = "DonutChartCell"
    let donutChartView = DonutChartView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(segments: [ChartSegment]) {
        let total = segments.reduce(0) { $0 + $1.value }
        donutChartView.total = total
        donutChartView.segments = segments
    }
    func setUpContentView() {
        backgroundColor = AppColor.background
        contentView.add(donutChartView)
        
        NSLayoutConstraint.activate([
            donutChartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            donutChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            donutChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            donutChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
