import XCTest
@testable import PointsPilot

final class MonthGridInputViewModelTests: XCTestCase {
    private var parentDelegateFake: DatePickerPanelDelegateFake!
    private var sut: MonthGridInputViewModel!

    override func setUp() {
        super.setUp()
        parentDelegateFake = DatePickerPanelDelegateFake()
        sut = MonthGridInputViewModel(parentDelegate: parentDelegateFake)
    }

    override func tearDown() {
        sut = nil
        parentDelegateFake = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_buildsTwelveMonths() {
        XCTAssertEqual(sut.months.count, 12)
    }

    func test_initialState_allMonthsAreSelectable() {
        for index in 0..<12 {
            XCTAssertEqual(sut.state(at: index), .selectable, "index \(index)")
        }
    }

    // MARK: - First selection

    func test_didTapMonth_firstSelection_marksTappedMonthAsSelected() {
        sut.didTapMonth(at: 5)

        XCTAssertEqual(sut.state(at: 5), .selected)
    }

    func test_didTapMonth_firstSelection_marksAdjacentMonthsAsSelectable() {
        sut.didTapMonth(at: 5)

        XCTAssertEqual(sut.state(at: 4), .selectable)
        XCTAssertEqual(sut.state(at: 6), .selectable)
    }

    func test_didTapMonth_firstSelection_marksNonAdjacentMonthsAsDisabled() {
        sut.didTapMonth(at: 5)

        for index in [0, 1, 2, 3, 7, 8, 9, 10, 11] {
            XCTAssertEqual(sut.state(at: index), .disabled, "index \(index)")
        }
    }

    func test_didTapMonth_firstSelection_atIndexZero_doesNotProduceNegativeNeighbor() {
        sut.didTapMonth(at: 0)

        XCTAssertEqual(sut.state(at: 0), .selected)
        XCTAssertEqual(sut.state(at: 1), .selectable)
        for index in 2..<12 {
            XCTAssertEqual(sut.state(at: index), .disabled, "index \(index)")
        }
    }

    func test_didTapMonth_firstSelection_atLastIndex_doesNotProduceOutOfBoundsNeighbor() {
        sut.didTapMonth(at: 11)

        XCTAssertEqual(sut.state(at: 11), .selected)
        XCTAssertEqual(sut.state(at: 10), .selectable)
        for index in 0..<10 {
            XCTAssertEqual(sut.state(at: index), .disabled, "index \(index)")
        }
    }

    // MARK: - Extending the range

    func test_didTapMonth_extendForward_growsRange() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 6)

        XCTAssertEqual(sut.state(at: 5), .selected)
        XCTAssertEqual(sut.state(at: 6), .selected)
        XCTAssertEqual(sut.state(at: 4), .selectable)
        XCTAssertEqual(sut.state(at: 7), .selectable)
        XCTAssertEqual(sut.state(at: 8), .disabled)
    }

    func test_didTapMonth_extendBackward_growsRange() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 4)

        XCTAssertEqual(sut.state(at: 4), .selected)
        XCTAssertEqual(sut.state(at: 5), .selected)
        XCTAssertEqual(sut.state(at: 3), .selectable)
        XCTAssertEqual(sut.state(at: 6), .selectable)
        XCTAssertEqual(sut.state(at: 2), .disabled)
    }

    // MARK: - Disabled taps

    func test_didTapMonth_onDisabled_doesNotChangeState() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 0) // disabled

        XCTAssertEqual(sut.state(at: 5), .selected)
        XCTAssertEqual(sut.state(at: 0), .disabled)
    }

    func test_didTapMonth_onDisabled_doesNotNotifyParent() {
        sut.didTapMonth(at: 5)
        let callsAfterFirstTap = parentDelegateFake.recorded.count

        sut.didTapMonth(at: 0) // disabled

        XCTAssertEqual(parentDelegateFake.recorded.count, callsAfterFirstTap)
    }

    // MARK: - Interior taps on selected months

    func test_didTapMonth_onInteriorSelected_doesNotChangeState() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 6)
        sut.didTapMonth(at: 7)
        // Range is now 5...7. Tap an interior cell.
        sut.didTapMonth(at: 6)

        XCTAssertEqual(sut.state(at: 5), .selected)
        XCTAssertEqual(sut.state(at: 6), .selected)
        XCTAssertEqual(sut.state(at: 7), .selected)
    }

    // MARK: - Shrinking the range

    func test_didTapMonth_onLowerEndpoint_shrinksFromBottom() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 6)
        sut.didTapMonth(at: 7)
        sut.didTapMonth(at: 5)

        XCTAssertEqual(sut.state(at: 5), .selectable)
        XCTAssertEqual(sut.state(at: 6), .selected)
        XCTAssertEqual(sut.state(at: 7), .selected)
        XCTAssertEqual(sut.state(at: 8), .selectable)
    }

    func test_didTapMonth_onUpperEndpoint_shrinksFromTop() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 6)
        sut.didTapMonth(at: 7)
        sut.didTapMonth(at: 7)

        XCTAssertEqual(sut.state(at: 5), .selected)
        XCTAssertEqual(sut.state(at: 6), .selected)
        XCTAssertEqual(sut.state(at: 7), .selectable)
        XCTAssertEqual(sut.state(at: 4), .selectable)
    }

    func test_didTapMonth_onSingleSelectedMonth_clearsSelection() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 5)

        for index in 0..<12 {
            XCTAssertEqual(sut.state(at: index), .selectable, "index \(index)")
        }
    }

    // MARK: - Parent notifications

    func test_didTapMonth_notifiesParentWithMatchingMonthRange() {
        sut.didTapMonth(at: 5)

        XCTAssertEqual(parentDelegateFake.recorded.count, 1)
        let recorded = parentDelegateFake.recorded[0]
        XCTAssertEqual(recorded.range.startDay, sut.months[5].firstDay)
        XCTAssertEqual(recorded.range.endDay, sut.months[5].lastDay)
    }

    func test_didTapMonth_clearingSingleSelection_notifiesParentWithFullYear() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 5)

        XCTAssertEqual(parentDelegateFake.recorded.last?.range, .fullYear)
    }

    func test_didTapMonth_extendingRange_notifiesParentSpanningFromFirstToLastSelected() {
        sut.didTapMonth(at: 5)
        sut.didTapMonth(at: 6)

        let recorded = parentDelegateFake.recorded.last
        XCTAssertEqual(recorded?.range.startDay, sut.months[5].firstDay)
        XCTAssertEqual(recorded?.range.endDay, sut.months[6].lastDay)
    }

    // MARK: - applyRange

    func test_applyRange_doesNotChangeCellStates() {
        sut.didTapMonth(at: 5)
        let before = (0..<12).map { sut.state(at: $0) }

        sut.applyRange(DayRange(startDay: 0, endDay: 30))

        let after = (0..<12).map { sut.state(at: $0) }
        XCTAssertEqual(before, after)
    }

    func test_applyRange_doesNotNotifyParent() {
        sut.applyRange(DayRange(startDay: 0, endDay: 30))

        XCTAssertTrue(parentDelegateFake.recorded.isEmpty)
    }
}
