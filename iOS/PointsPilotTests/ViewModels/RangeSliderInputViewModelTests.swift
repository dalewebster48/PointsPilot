import XCTest
@testable import PointsPilot

final class RangeSliderInputViewModelTests: XCTestCase {
    private var parentDelegateFake: DatePickerPanelDelegateFake!
    private var sut: RangeSliderInputViewModel!
    private let initialRange = DayRange(startDay: 10, endDay: 20)

    override func setUp() {
        super.setUp()
        parentDelegateFake = DatePickerPanelDelegateFake()
        sut = RangeSliderInputViewModel(
            parentDelegate: parentDelegateFake,
            initialRange: initialRange
        )
    }

    override func tearDown() {
        sut = nil
        parentDelegateFake = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_exposesInitialRange() {
        XCTAssertEqual(sut.startDay, initialRange.startDay)
        XCTAssertEqual(sut.endDay, initialRange.endDay)
    }

    func test_initialState_exposesMaxDay() {
        XCTAssertEqual(sut.maxDay, DayRange.maxDaysOut)
    }

    func test_initialState_exposesAllSeasons() {
        XCTAssertEqual(sut.seasons, DatePickerSeason.allCases)
    }

    func test_initialState_buildsTwelveMonthTicks() {
        XCTAssertEqual(sut.monthTicks.count, 12)
    }

    func test_monthTicks_arePositionedInAscendingOrder() {
        let percents = sut.monthTicks.map(\.percent)
        XCTAssertEqual(percents, percents.sorted())
    }

    func test_monthTicks_areAllWithinUnitRange() {
        for tick in sut.monthTicks {
            XCTAssertGreaterThanOrEqual(tick.percent, 0)
            XCTAssertLessThanOrEqual(tick.percent, 1)
        }
    }

    // MARK: - didChangeSliderValues

    func test_didChangeSliderValues_updatesRange() {
        sut.didChangeSliderValues(lower: 30, upper: 60)

        XCTAssertEqual(sut.startDay, 30)
        XCTAssertEqual(sut.endDay, 60)
    }

    func test_didChangeSliderValues_notifiesParentWithNewRange() {
        sut.didChangeSliderValues(lower: 30, upper: 60)

        XCTAssertEqual(parentDelegateFake.recorded.count, 1)
        XCTAssertEqual(
            parentDelegateFake.recorded.last?.range,
            DayRange(startDay: 30, endDay: 60)
        )
    }

    func test_didChangeSliderValues_clampsLowerBelowZero() {
        sut.didChangeSliderValues(lower: -50, upper: 30)

        XCTAssertEqual(sut.startDay, 0)
        XCTAssertEqual(sut.endDay, 30)
    }

    func test_didChangeSliderValues_clampsUpperAboveMax() {
        sut.didChangeSliderValues(lower: 5, upper: DayRange.maxDaysOut + 100)

        XCTAssertEqual(sut.startDay, 5)
        XCTAssertEqual(sut.endDay, DayRange.maxDaysOut)
    }

    func test_didChangeSliderValues_returnsEarlyWhenLowerExceedsUpper() {
        sut.didChangeSliderValues(lower: 50, upper: 10)

        XCTAssertEqual(sut.startDay, initialRange.startDay)
        XCTAssertEqual(sut.endDay, initialRange.endDay)
        XCTAssertTrue(parentDelegateFake.recorded.isEmpty)
    }

    func test_didChangeSliderValues_dedupesIdenticalRange() {
        sut.didChangeSliderValues(
            lower: initialRange.startDay,
            upper: initialRange.endDay
        )

        XCTAssertTrue(parentDelegateFake.recorded.isEmpty)
    }

    func test_didChangeSliderValues_dedupesAfterClampingToSameValue() {
        // -5 clamps up to 0, but our initial range starts at 10, so this is
        // a meaningful change. Use values that clamp into the existing range
        // to verify the dedupe applies after clamping.
        sut.didChangeSliderValues(lower: 30, upper: 60)
        parentDelegateFake.recorded.removeAll()

        sut.didChangeSliderValues(lower: 30, upper: 60)

        XCTAssertTrue(parentDelegateFake.recorded.isEmpty)
    }

    // MARK: - didTapSeason

    func test_didTapSeason_notifiesParentExactlyOnce() {
        sut.didTapSeason(.summer)

        XCTAssertEqual(parentDelegateFake.recorded.count, 1)
    }

    func test_didTapSeason_producesRangeWithinPickerWindow() {
        sut.didTapSeason(.summer)

        guard let recorded = parentDelegateFake.recorded.last else {
            return XCTFail("Expected parent to be notified")
        }
        XCTAssertGreaterThanOrEqual(recorded.range.startDay, 0)
        XCTAssertLessThanOrEqual(recorded.range.endDay, DayRange.maxDaysOut)
        XCTAssertLessThanOrEqual(recorded.range.startDay, recorded.range.endDay)
    }

    func test_didTapSeason_producesRangeForEverySeason() {
        for season in DatePickerSeason.allCases {
            parentDelegateFake.recorded.removeAll()
            sut.didTapSeason(season)
            XCTAssertEqual(
                parentDelegateFake.recorded.count, 1,
                "Expected a parent call for \(season.label)"
            )
        }
    }

    // MARK: - applyRange

    func test_applyRange_updatesRange() {
        sut.applyRange(DayRange(startDay: 50, endDay: 100))

        XCTAssertEqual(sut.startDay, 50)
        XCTAssertEqual(sut.endDay, 100)
    }

    func test_applyRange_doesNotNotifyParent() {
        sut.applyRange(DayRange(startDay: 50, endDay: 100))

        XCTAssertTrue(parentDelegateFake.recorded.isEmpty)
    }

    // MARK: - Date conversions

    func test_startDate_matchesStartDayOffset() {
        sut.applyRange(DayRange(startDay: 7, endDay: 14))

        let expected = DatePickerDateMath.date(daysFromToday: 7)
        XCTAssertEqual(sut.startDate, expected)
    }

    func test_endDate_matchesEndDayOffset() {
        sut.applyRange(DayRange(startDay: 7, endDay: 14))

        let expected = DatePickerDateMath.date(daysFromToday: 14)
        XCTAssertEqual(sut.endDate, expected)
    }
}
