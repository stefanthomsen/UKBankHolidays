import XCTest
@testable import UKBankHolidays

final class UKBankHolidaysTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchData_Success() {
        // GIVEN
        let sut = BankHolidaysViewModel(service: FakeSuccessService(), dispatchQueue: DispatchQueueMock(label: "queue"))
        
        let expectation = self.expectation(description: "queue")
        sut.holidaysListDidChange = { viewModel in
            if case .loaded = viewModel.viewStatus {
                expectation.fulfill()
            }
        }
        // WHEN
        sut.fetchBankHolidays()
        
        // THEN
        XCTAssertNotNil(sut.bankHoliday)
        XCTAssertEqual(sut.events.count, 1)
        
        XCTAssertEqual(sut.events[0].title, "Title")
        XCTAssertEqual(sut.events[0].date, "Date")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchData_Fail() {
        // GIVEN
        let sut = BankHolidaysViewModel(service: FakeFailService())
        
        // WHEN
        sut.fetchBankHolidays()
        
        // THEN
        XCTAssertNil(sut.bankHoliday)
    }
    
    func testDidSelectSegmentControl() {
        // GIVEN
        let sut = BankHolidaysViewModel(service: FakeSuccessService())
        sut.fetchBankHolidays()
        
        for region in BankHolidaysViewModel.Region.allCases {
            // WHEN
            sut.didSelectSegmentControl(index: region.rawValue)
            
            // THEN
            XCTAssertEqual(sut.region, region)
            XCTAssertEqual(sut.events[0].title, "Title")
            XCTAssertEqual(sut.events[0].date, "Date")
        }
    }

}


private class FakeSuccessService: BankHolidaysServiceProtocol {
    func fetchBankHolidays(completion: @escaping (Result<UKBankHolidays.BankHoliday, Error>) -> Void) {
        completion(.success(.mock))
    }
}

private class FakeFailService: BankHolidaysServiceProtocol {
    func fetchBankHolidays(completion: @escaping (Result<UKBankHolidays.BankHoliday, Error>) -> Void) {
        let error = NSError(domain: "error", code: 400)
        completion(.failure(error as Error))
    }
}


private extension BankHoliday {
    static let mock = BankHoliday(
        englandAndWales:.mock,
        scotland: .mock,
        northernIreland: .mock
    )
}

private extension EnglandAndWales {
    static let mock = EnglandAndWales(division: "", events: [.mock])
}


private extension Event {
    static let mock = Event(title: "Title", date: "Date", notes: .mock, bunting: true)
}

private extension Notes {
    static let mock = Notes.empty
}

final class DispatchQueueMock: DispatchQueue {
    func async(execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
