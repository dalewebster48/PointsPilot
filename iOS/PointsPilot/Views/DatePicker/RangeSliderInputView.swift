import UIKit

final class RangeSliderInputView: UIView {
    private let stack = UIStackView()

    private let fromLabel = UILabel()
    private let toLabel = UILabel()
    private let fromDateLabel = UILabel()
    private let toDateLabel = UILabel()

    private let rangeSlider = RangeSlider()
    private let ticksContainer = MonthTicksRowView()

    private let seasonStack = UIStackView()
    private var seasonButtons: [SeasonPillButton] = []

    private var viewModel: (any RangeSliderInputViewModelProtocol)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: any RangeSliderInputViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.viewDelegate = self

        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = Double(viewModel.maxDay)
        rangeSlider.lowerValue = Double(viewModel.startDay)
        rangeSlider.upperValue = Double(viewModel.endDay)
        ticksContainer.ticks = viewModel.monthTicks

        rebuildSeasonButtons(for: viewModel.seasons)
        applyDateLabels()
    }

    private func commonInit() {
        backgroundColor = .clear

        fromLabel.text = "From"
        toLabel.text = "To"
        [fromLabel, toLabel].forEach { label in
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            label.textColor = Theme.secondaryLabel
        }
        toLabel.textAlignment = .right

        [fromDateLabel, toDateLabel].forEach { label in
            label.font = .systemFont(ofSize: 22, weight: .bold)
            label.textColor = Theme.primaryLabel
        }
        toDateLabel.textAlignment = .right

        let fromColumn = UIStackView(arrangedSubviews: [fromLabel, fromDateLabel])
        fromColumn.axis = .vertical
        fromColumn.alignment = .leading
        fromColumn.spacing = 2

        let toColumn = UIStackView(arrangedSubviews: [toLabel, toDateLabel])
        toColumn.axis = .vertical
        toColumn.alignment = .trailing
        toColumn.spacing = 2

        let datesRow = UIStackView(arrangedSubviews: [fromColumn, toColumn])
        datesRow.axis = .horizontal
        datesRow.distribution = .equalSpacing

        rangeSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rangeSlider.heightAnchor.constraint(equalToConstant: 44)
        ])

        ticksContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ticksContainer.heightAnchor.constraint(equalToConstant: 14)
        ])

        seasonStack.axis = .horizontal
        seasonStack.spacing = 8
        seasonStack.alignment = .center
        seasonStack.distribution = .fillEqually

        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(datesRow)
        stack.addArrangedSubview(rangeSlider)
        stack.addArrangedSubview(ticksContainer)
        stack.addArrangedSubview(seasonStack)
        stack.setCustomSpacing(4, after: rangeSlider)
        stack.setCustomSpacing(18, after: ticksContainer)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func sliderValueChanged() {
        guard let viewModel else { return }
        let lower = Int(rangeSlider.lowerValue.rounded())
        let upper = Int(rangeSlider.upperValue.rounded())
        viewModel.didChangeSliderValues(lower: lower, upper: upper)
    }

    @objc private func seasonTapped(_ sender: SeasonPillButton) {
        viewModel?.didTapSeason(sender.season)
    }

    private func rebuildSeasonButtons(for seasons: [DatePickerSeason]) {
        seasonButtons.forEach { $0.removeFromSuperview() }
        seasonButtons.removeAll()
        for season in seasons {
            let button = SeasonPillButton(season: season)
            button.addTarget(self, action: #selector(seasonTapped(_:)), for: .touchUpInside)
            seasonButtons.append(button)
            seasonStack.addArrangedSubview(button)
        }
    }

    private func applyDateLabels() {
        guard let viewModel else { return }
        fromDateLabel.text = DateFormatter.monthDay.string(from: viewModel.startDate)
        toDateLabel.text = DateFormatter.monthDay.string(from: viewModel.endDate)
    }
}

// MARK: - RangeSliderInputViewModelViewDelegate

extension RangeSliderInputView: RangeSliderInputViewModelViewDelegate {
    func bind(viewModel: any RangeSliderInputViewModelProtocol) {
        rangeSlider.lowerValue = Double(viewModel.startDay)
        rangeSlider.upperValue = Double(viewModel.endDay)
        applyDateLabels()
    }
}

// MARK: - SeasonPillButton

private final class SeasonPillButton: UIButton {
    let season: DatePickerSeason

    init(season: DatePickerSeason) {
        self.season = season
        var config = UIButton.Configuration.plain()
        config.title = season.label
        config.baseForegroundColor = Theme.primaryLabel
        config.background.backgroundColor = Theme.secondaryBackground
        config.background.cornerRadius = 14
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        var attributes = AttributeContainer()
        attributes.font = .systemFont(ofSize: 13, weight: .medium)
        config.attributedTitle = AttributedString(season.label, attributes: attributes)
        super.init(frame: .zero)
        configuration = config
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - MonthTicksRowView

private final class MonthTicksRowView: UIView {
    var ticks: [DatePickerMonthTick] = [] {
        didSet { rebuildLabels() }
    }

    private var labelByPercent: [(label: UILabel, percent: Double)] = []

    private func rebuildLabels() {
        labelByPercent.forEach { $0.label.removeFromSuperview() }
        labelByPercent.removeAll()
        for tick in ticks {
            let label = UILabel()
            label.text = tick.letter
            label.font = .systemFont(ofSize: 9, weight: .semibold)
            label.textColor = Theme.secondaryLabel
            addSubview(label)
            labelByPercent.append((label, tick.percent))
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for entry in labelByPercent {
            entry.label.sizeToFit()
            let centerX = bounds.width * CGFloat(entry.percent)
            entry.label.center = CGPoint(x: centerX, y: bounds.midY)
        }
    }
}
