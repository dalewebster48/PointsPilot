import UIKit

final class DatePickerSnapFlowLayout: UICollectionViewFlowLayout {
    // For tall cells: how far past the cell's top the user must have
    // scrolled before we allow free-scrolling within it.
    private let tallCellEntryDepth: CGFloat = 0.15

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView else { return proposedContentOffset }

        let proposedTop = proposedContentOffset.y
        let releaseY = collectionView.contentOffset.y
        let viewHeight = collectionView.bounds.height

        // Only consider cells currently in the viewport. This caps the snap
        // target to a cell adjacent to where the user is — a hard flick can't
        // skip past anything because cells beyond the visible region aren't
        // even candidates.
        let cells = (layoutAttributesForElements(in: collectionView.bounds) ?? [])
            .filter { $0.representedElementCategory == .cell }

        // Tall-cell exception: once the user has scrolled into a cell taller
        // than the viewport, leave the proposed offset alone so deceleration
        // carries naturally through the content.
        if let containing = cells.first(where: { $0.frame.minY <= releaseY && releaseY < $0.frame.maxY }),
           containing.frame.height > viewHeight,
           releaseY > containing.frame.minY + viewHeight * tallCellEntryDepth {
            return proposedContentOffset
        }

        // Snap to whichever visible cell's top is closest to where
        // deceleration would have landed.
        let target = cells.min(by: {
            abs($0.frame.minY - proposedTop) < abs($1.frame.minY - proposedTop)
        })
        guard let target else { return proposedContentOffset }

        return CGPoint(x: proposedContentOffset.x, y: target.frame.minY)
    }
}
