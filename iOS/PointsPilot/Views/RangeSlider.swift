import UIKit

final class RangeSlider: UIControl {
    var minimumValue: Double = 0 { didSet { setNeedsLayout() } }
    var maximumValue: Double = 1 { didSet { setNeedsLayout() } }
    var lowerValue: Double = 0 { didSet { setNeedsLayout() } }
    var upperValue: Double = 1 { didSet { setNeedsLayout() } }
    var minimumGap: Double = 1

    private let trackLayer = CALayer()
    private let highlightLayer = CALayer()
    private let lowerThumbLayer = CALayer()
    private let upperThumbLayer = CALayer()

    private weak var trackedThumb: CALayer?

    private let thumbSize: CGFloat = 28
    private let trackHeight: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: thumbSize + 8)
    }

    private func commonInit() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(highlightLayer)
        layer.addSublayer(lowerThumbLayer)
        layer.addSublayer(upperThumbLayer)

        trackLayer.cornerRadius = trackHeight / 2
        highlightLayer.cornerRadius = trackHeight / 2
        lowerThumbLayer.cornerRadius = thumbSize / 2
        upperThumbLayer.cornerRadius = thumbSize / 2

        for thumb in [lowerThumbLayer, upperThumbLayer] {
            thumb.shadowColor = UIColor.black.cgColor
            thumb.shadowOpacity = 0.2
            thumb.shadowRadius = 2
            thumb.shadowOffset = CGSize(width: 0, height: 1)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        addGestureRecognizer(pan)

        applyTheme()
    }

    private func applyTheme() {
        trackLayer.backgroundColor = Theme.separator.cgColor
        highlightLayer.backgroundColor = Theme.primaryAccent.cgColor
        lowerThumbLayer.backgroundColor = UIColor.white.cgColor
        upperThumbLayer.backgroundColor = UIColor.white.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let trackY = (bounds.height - trackHeight) / 2
        let trackInset = thumbSize / 2
        trackLayer.frame = CGRect(
            x: trackInset,
            y: trackY,
            width: bounds.width - trackInset * 2,
            height: trackHeight
        )

        let lowerX = positionForValue(lowerValue)
        let upperX = positionForValue(upperValue)
        highlightLayer.frame = CGRect(x: lowerX, y: trackY, width: upperX - lowerX, height: trackHeight)

        let thumbY = (bounds.height - thumbSize) / 2
        lowerThumbLayer.frame = CGRect(x: lowerX - thumbSize / 2, y: thumbY, width: thumbSize, height: thumbSize)
        upperThumbLayer.frame = CGRect(x: upperX - thumbSize / 2, y: thumbY, width: thumbSize, height: thumbSize)
    }

    private func positionForValue(_ value: Double) -> CGFloat {
        guard maximumValue > minimumValue else { return thumbSize / 2 }
        let trackInset = thumbSize / 2
        let trackWidth = bounds.width - trackInset * 2
        let ratio = (value - minimumValue) / (maximumValue - minimumValue)
        return trackInset + CGFloat(ratio) * trackWidth
    }

    private func valueForPosition(_ position: CGFloat) -> Double {
        let trackInset = thumbSize / 2
        let trackWidth = bounds.width - trackInset * 2
        guard trackWidth > 0 else { return minimumValue }
        let ratio = Double((position - trackInset) / trackWidth)
        return minimumValue + ratio * (maximumValue - minimumValue)
    }

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: self)
        switch pan.state {
        case .began:
            let lowerDist = abs(location.x - lowerThumbLayer.frame.midX)
            let upperDist = abs(location.x - upperThumbLayer.frame.midX)
            if lowerDist < upperDist {
                trackedThumb = lowerThumbLayer
            } else if upperDist < lowerDist {
                trackedThumb = upperThumbLayer
            } else {
                trackedThumb = location.x > lowerThumbLayer.frame.midX ? upperThumbLayer : lowerThumbLayer
            }
        case .changed:
            guard let trackedThumb else { return }
            let raw = valueForPosition(location.x)
            let clamped = min(max(raw, minimumValue), maximumValue)
            if trackedThumb === lowerThumbLayer {
                lowerValue = min(clamped, upperValue - minimumGap)
            } else {
                upperValue = max(clamped, lowerValue + minimumGap)
            }
            sendActions(for: .valueChanged)
        case .ended, .cancelled, .failed:
            trackedThumb = nil
        default:
            break
        }
    }
}

extension RangeSlider: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy other: UIGestureRecognizer
    ) -> Bool {
        other is UIScreenEdgePanGestureRecognizer
    }
}
