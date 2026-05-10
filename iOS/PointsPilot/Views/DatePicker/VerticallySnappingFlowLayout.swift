import UIKit

private extension Int {
    var indexPath: IndexPath {
        IndexPath(row: self, section: 0)
    }
    var nextIndexPath: IndexPath {
        IndexPath(row: self + 1, section: 0)
    }
    var prevIndexPath: IndexPath {
        IndexPath(row: self - 1, section: 0)
    }
}

private extension UICollectionView {
    /// Returns the position of an element relative to the frame (adjusted for content offset)
    func adjustedPosition(_ point: CGPoint) -> CGPoint {
        .init(x: point.x - contentOffset.x, y: point.y - contentOffset.y)
    }
}

final class VerticallySnappingFlowLayout: UICollectionViewFlowLayout {
    // The relative size of a cell compared to the frame for it to be classified as tall
    private static let TALL_CELL_THRESHOLD: CGFloat = 0.7
    
    // The threshold from either the top or bottom of the screen that we need to snap to the panel's top
    private static let SNAP_THRESHOLD: CGFloat = 20
    
    private var currentCell: Int = 0
    private var startingPoint: CGPoint = .zero
    
    func suggestedContentOffset(for currentContentOffset: CGPoint) -> CGPoint {
        guard let collectionView, let currentAttrs = layoutAttributesForItem(at: currentCell.indexPath) else { return .zero }
        
        let totalItems = collectionView.numberOfItems(inSection: 0)
        let prevAttrs = (currentCell > 0) ? layoutAttributesForItem(at: currentCell.prevIndexPath) : nil
        let nextAttrs = (currentCell < totalItems - 1) ? layoutAttributesForItem(at: currentCell.nextIndexPath) : nil
        
        // A panel is 'tall' if its height exceeds the height of the visible frame
        let currentPanelIsTall = currentAttrs.frame.height > (collectionView.bounds.height - collectionView.contentInset.bottom)
        
        if !currentPanelIsTall {
            // For small panels interactions always result in a snap, whether back to their top or
            // to an adjacent panel
            let frame = currentAttrs.frame
            if collectionView.adjustedPosition(frame.origin).y < Self.SNAP_THRESHOLD && nextAttrs != nil {
                // scroll down
                currentCell += 1
                startingPoint = nextAttrs!.frame.origin
                return startingPoint
            } else if (collectionView.adjustedPosition(frame.origin).y > Self.SNAP_THRESHOLD) && prevAttrs != nil {
                // scroll up
                currentCell -= 1
                startingPoint = prevAttrs!.frame.origin
                return startingPoint
            } else {
                // Snap back to the current cell
                startingPoint = currentAttrs.frame.origin
                return startingPoint
            }
        } else {
            /*
             For large panels we have primarily normal scrolling.
             If starting point is the origin and the user has scrolled up, then we snap back one
             If starting point is the origin + height (the bottom) and the user has scrolled down, then we snap
             forward one
             
             Otherwise, if the user scrolls within a threshold of the top then we snap to the top, and
             if the user scrolls passed the bottom, then we snap to the bottom
             */
            //            let relPanelOrigin = collectionView.adjustedPosition(currentAttrs.frame.origin)
            let relPanelOrigin = CGPoint(x: currentAttrs.frame.origin.x - currentContentOffset.x, y: currentAttrs.frame.origin.y - currentContentOffset.y)
            let relPanelBottom = CGPoint(x: relPanelOrigin.x, y: relPanelOrigin.y + currentAttrs.frame.height)
            let absPanelBottom = CGPoint(x: currentAttrs.frame.origin.x, y: currentAttrs.frame.origin.y + currentAttrs.frame.height)
            let startedAtTop = startingPoint.y == currentAttrs.frame.origin.y
            let startedAtBottom = startingPoint.y == absPanelBottom.y
            if startedAtTop {
                // We started at the top
                if relPanelOrigin.y > Self.SNAP_THRESHOLD && prevAttrs != nil {
                    // User is scrolling up, snap back
                    currentCell -= 1
                    startingPoint = prevAttrs!.frame.origin
                    return startingPoint
                } else if relPanelOrigin.y > 0 {
                    // They're moving up but not enough to snap, so just reset back to the top
                    startingPoint = currentAttrs.frame.origin
                    return startingPoint
                } else {
                    // They must be moving downwards so this is a normal scroll
                    startingPoint = currentContentOffset
                    return startingPoint
                }
            } else if startedAtBottom {
                if relPanelBottom.y > (collectionView.frame.height + Self.SNAP_THRESHOLD) && nextAttrs != nil {
                    // User is scrolling down
                    currentCell += 1
                    startingPoint = nextAttrs!.frame.origin
                    return startingPoint
                } else if relPanelBottom.y > collectionView.frame.height {
                    // Scrolling down but not enough, snap to the bottom of the panel
                    startingPoint = absPanelBottom
                    return startingPoint
                } else {
                    // Ordinary scrolling upwards
                    startingPoint = currentContentOffset
                    return startingPoint
                }
            } else {
                // This is a standard free scroll with snapping when scrolling beyond the bounds
                if relPanelOrigin.y > 0 {
                    // Snap to the top of the panel
                    startingPoint = currentAttrs.frame.origin
                    return startingPoint
                } else if relPanelBottom.y < (collectionView.frame.height - collectionView.contentInset.bottom) {
                    // Snap to the bottom
                    startingPoint = absPanelBottom
                    return startingPoint
                } else {
                    return currentContentOffset
                }
            }
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        suggestedContentOffset(for: proposedContentOffset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)?.enumerated().map { index, originalAttrs in
            let attrs = originalAttrs.copy() as! UICollectionViewLayoutAttributes
            attrs.alpha = index == currentCell ? 1 : 0.5
            return attrs
        }
    }
}
