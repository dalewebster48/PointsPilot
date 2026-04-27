import UIKit

final class MonthGridInputView: UIView {
    private let columnCount = 3
    private let spacing: CGFloat = 10
    private let rowHeight: CGFloat = 56

    private let collectionView: UICollectionView
    private let layout = UICollectionViewFlowLayout()

    private var viewModel: (any MonthGridInputViewModelProtocol)?

    override init(frame: CGRect) {
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: any MonthGridInputViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.viewDelegate = self
        collectionView.reloadData()
        applySelections()
    }

    private func commonInit() {
        backgroundColor = .clear

        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            UINib(nibName: "SelectablePillCell", bundle: nil),
            forCellWithReuseIdentifier: SelectablePillCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override var intrinsicContentSize: CGSize {
        // 12 months in a 3-column grid → 4 rows. Plus 3 inter-row gaps.
        let rows = 4
        let totalSpacing = spacing * CGFloat(rows - 1)
        return CGSize(width: UIView.noIntrinsicMetric, height: rowHeight * CGFloat(rows) + totalSpacing)
    }

    private func applySelections() {
        guard let viewModel else { return }
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        for index in viewModel.selectedIndices {
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
        }
    }

    private func itemWidth(for boundsWidth: CGFloat) -> CGFloat {
        let totalSpacing = spacing * CGFloat(columnCount - 1)
        return floor((boundsWidth - totalSpacing) / CGFloat(columnCount))
    }
}

// MARK: - MonthGridInputViewModelViewDelegate

extension MonthGridInputView: MonthGridInputViewModelViewDelegate {
    func bind(viewModel: any MonthGridInputViewModelProtocol) {
        applySelections()
    }
}

// MARK: - UICollectionViewDataSource

extension MonthGridInputView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.months.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectablePillCell.reuseIdentifier,
            for: indexPath
        ) as! SelectablePillCell
        if let month = viewModel?.months[indexPath.item] {
            cell.configure(title: month.label, subtitle: month.year, size: .large)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MonthGridInputView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: itemWidth(for: collectionView.bounds.width), height: rowHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel?.didTapMonth(at: indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        viewModel?.didTapMonth(at: indexPath.item)
    }
}
