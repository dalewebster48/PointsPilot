import UIKit

protocol MiniMonthViewDelegate: AnyObject {
    func miniMonthView(_ view: MiniMonthView, didTapYear year: Int, month: Int, day: Int)
}

final class MiniMonthView: UIView {
    enum DayState {
        case idle
        case mid
        case start
        case end
        case disabled
    }

    weak var delegate: (any MiniMonthViewDelegate)?

    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let gridStack = UIStackView()

    private var monthDescriptor: DatePickerCalendarMonth?
    private var dayCells: [Int: DayCell] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(month: DatePickerCalendarMonth) {
        monthDescriptor = month
        titleLabel.text = month.longName
        yearLabel.text = String(month.year)
        rebuildGrid(for: month)
    }

    func applyStates(rangeStart: Date, rangeEnd: Date) {
        guard let monthDescriptor else { return }
        let calendar = Calendar.current
        for (day, cell) in dayCells {
            let isInSelectableWindow = day >= monthDescriptor.earliestSelectableDayInMonth
                && day <= monthDescriptor.latestSelectableDayInMonth
            guard isInSelectableWindow else {
                cell.dayState = .disabled
                continue
            }
            guard let dayDate = calendar.date(from: DateComponents(
                year: monthDescriptor.year,
                month: monthDescriptor.monthIndex,
                day: day
            )) else {
                cell.dayState = .disabled
                continue
            }
            let isStart = calendar.isDate(dayDate, inSameDayAs: rangeStart)
            let isEnd = calendar.isDate(dayDate, inSameDayAs: rangeEnd)
            if isStart && isEnd {
                cell.dayState = .start
            } else if isStart {
                cell.dayState = .start
            } else if isEnd {
                cell.dayState = .end
            } else if dayDate > rangeStart && dayDate < rangeEnd {
                cell.dayState = .mid
            } else {
                cell.dayState = .idle
            }
        }
    }

    private func commonInit() {
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = Theme.primaryLabel

        yearLabel.font = .systemFont(ofSize: 9, weight: .medium)
        yearLabel.textColor = Theme.secondaryLabel
        yearLabel.textAlignment = .right

        let header = UIStackView(arrangedSubviews: [titleLabel, yearLabel])
        header.axis = .horizontal
        header.alignment = .firstBaseline
        header.distribution = .equalSpacing

        gridStack.axis = .vertical
        gridStack.spacing = 1
        gridStack.alignment = .fill
        gridStack.distribution = .fillEqually

        let outerStack = UIStackView(arrangedSubviews: [header, gridStack])
        outerStack.axis = .vertical
        outerStack.spacing = 6
        outerStack.alignment = .fill
        outerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func rebuildGrid(for month: DatePickerCalendarMonth) {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dayCells.removeAll()

        let totalCells = month.leadingEmptyDayCells + month.dayCount
        let rowCount = Int((Double(totalCells) / 7.0).rounded(.up))

        var dayCounter = 1
        for rowIndex in 0..<rowCount {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 1
            row.alignment = .fill
            row.distribution = .fillEqually

            for columnIndex in 0..<7 {
                let cellIndex = rowIndex * 7 + columnIndex
                let isLeadingEmpty = cellIndex < month.leadingEmptyDayCells
                if isLeadingEmpty || dayCounter > month.dayCount {
                    let placeholder = UIView()
                    NSLayoutConstraint.activate([
                        placeholder.heightAnchor.constraint(equalTo: placeholder.widthAnchor)
                    ])
                    row.addArrangedSubview(placeholder)
                } else {
                    let cell = DayCell()
                    cell.dayNumber = dayCounter
                    cell.onTap = { [weak self, day = dayCounter] in
                        guard let self, let monthDescriptor = self.monthDescriptor else { return }
                        self.delegate?.miniMonthView(
                            self,
                            didTapYear: monthDescriptor.year,
                            month: monthDescriptor.monthIndex,
                            day: day
                        )
                    }
                    NSLayoutConstraint.activate([
                        cell.heightAnchor.constraint(equalTo: cell.widthAnchor)
                    ])
                    dayCells[dayCounter] = cell
                    row.addArrangedSubview(cell)
                    dayCounter += 1
                }
            }

            gridStack.addArrangedSubview(row)
        }
    }
}

// MARK: - DayCell

private final class DayCell: UIControl {
    var dayNumber: Int = 0 {
        didSet { label.text = String(dayNumber) }
    }

    var onTap: (() -> Void)?

    var dayState: MiniMonthView.DayState = .idle {
        didSet { applyState() }
    }

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        applyState()
    }

    @objc private func handleTap() {
        guard dayState != .disabled else { return }
        onTap?()
    }

    private func applyState() {
        switch dayState {
        case .idle:
            backgroundColor = .clear
            label.textColor = Theme.primaryLabel
            label.font = .systemFont(ofSize: 10, weight: .medium)
            layer.cornerRadius = 6
            isUserInteractionEnabled = true
        case .mid:
            backgroundColor = Theme.primaryAccent.withAlphaComponent(0.13)
            label.textColor = Theme.primaryAccent
            label.font = .systemFont(ofSize: 10, weight: .bold)
            layer.cornerRadius = 3
            isUserInteractionEnabled = true
        case .start:
            backgroundColor = Theme.primaryAccent
            label.textColor = .white
            label.font = .systemFont(ofSize: 10, weight: .bold)
            layer.cornerRadius = 6
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            isUserInteractionEnabled = true
        case .end:
            backgroundColor = Theme.primaryAccent
            label.textColor = .white
            label.font = .systemFont(ofSize: 10, weight: .bold)
            layer.cornerRadius = 6
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            isUserInteractionEnabled = true
        case .disabled:
            backgroundColor = .clear
            label.textColor = Theme.secondaryLabel.withAlphaComponent(0.4)
            label.font = .systemFont(ofSize: 10, weight: .medium)
            layer.cornerRadius = 6
            isUserInteractionEnabled = false
        }
    }
}
