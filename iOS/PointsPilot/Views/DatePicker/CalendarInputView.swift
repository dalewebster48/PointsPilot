import UIKit

final class CalendarInputView: UIView {
    private let outerStack = UIStackView()
    private var miniMonthViews: [MiniMonthView] = []

    private var viewModel: (any CalendarInputViewModelProtocol)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: any CalendarInputViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.viewDelegate = self
        rebuildMonths(viewModel.months)
        applyStates()
    }

    private func commonInit() {
        backgroundColor = .clear

        outerStack.axis = .vertical
        outerStack.spacing = 12
        outerStack.alignment = .fill
        outerStack.distribution = .fill
        outerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func rebuildMonths(_ months: [DatePickerCalendarMonth]) {
        outerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        miniMonthViews.removeAll()

        // Lay out months in rows of 2 (the design's 6×2 grid).
        for rowStart in stride(from: 0, to: months.count, by: 2) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .top
            row.distribution = .fillEqually

            let leftMonth = MiniMonthView()
            leftMonth.delegate = self
            leftMonth.configure(month: months[rowStart])
            miniMonthViews.append(leftMonth)
            row.addArrangedSubview(leftMonth)

            if rowStart + 1 < months.count {
                let rightMonth = MiniMonthView()
                rightMonth.delegate = self
                rightMonth.configure(month: months[rowStart + 1])
                miniMonthViews.append(rightMonth)
                row.addArrangedSubview(rightMonth)
            } else {
                // Pad the trailing slot so the lone month doesn't stretch full-width.
                row.addArrangedSubview(UIView())
            }

            outerStack.addArrangedSubview(row)
        }
    }

    private func applyStates() {
        guard let viewModel else { return }
        miniMonthViews.forEach {
            $0.applyStates(rangeStart: viewModel.startDate, rangeEnd: viewModel.endDate)
        }
    }
}

// MARK: - CalendarInputViewModelViewDelegate

extension CalendarInputView: CalendarInputViewModelViewDelegate {
    func bind(viewModel: any CalendarInputViewModelProtocol) {
        applyStates()
    }
}

// MARK: - MiniMonthViewDelegate

extension CalendarInputView: MiniMonthViewDelegate {
    func miniMonthView(
        _ view: MiniMonthView,
        didTapYear year: Int,
        month: Int,
        day: Int
    ) {
        viewModel?.didTapDay(year: year, month: month, day: day)
    }
}
