import Foundation
import UIKit

enum ViewStatus {
    case loading
    case loaded
    case failed(Error)
}

protocol BankHolidaysViewModelProtocol: AnyObject {
    
    var viewStatus: ViewStatus { get }
    var region: BankHolidaysViewModel.Region { get }
    var events: [Event] { get }
    var holidaysListDidChange: ((BankHolidaysViewModelProtocol) -> ())? { get set }
    
    func fetchBankHolidays()
    func didSelectSegmentControl(index: Int)
}

class BankHolidaysViewModel: BankHolidaysViewModelProtocol {
    
    enum Region: Int, CaseIterable {
        case englandAndWales = 0
        case scotland
        case northernIreland
        
        var title: String {
            switch self {
            case .englandAndWales:
                return "England and Wales"
            case .scotland:
                return "Scotland"
            case .northernIreland:
                return "Northern Ireland"
            }
        }
    }
    
    var viewStatus: ViewStatus = .loading
    var bankHoliday: BankHoliday?
    var region: Region = .englandAndWales
    var holidaysListDidChange: ((BankHolidaysViewModelProtocol) -> ())?
    private let service: BankHolidaysServiceProtocol
    private let dispatchQueue: DispatchQueue
    
    init(service: BankHolidaysServiceProtocol = BankHolidaysService(),
         dispatchQueue: DispatchQueue = DispatchQueue.main) {
        
        self.service = service
        self.dispatchQueue = dispatchQueue
    }
    
    func fetchBankHolidays() {
        viewStatus = .loading
        self.holidaysListDidChange?(self)
        service.fetchBankHolidays { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let bankHoliday):
                self.bankHoliday = bankHoliday
                self.viewStatus = .loaded
            case .failure(let error):
                self.viewStatus = .failed(error)
            }
            self.dispatchQueue.async {
                self.holidaysListDidChange?(self)
            }
        }
    }
    
    func didSelectSegmentControl(index: Int) {
        guard let region = BankHolidaysViewModel.Region(rawValue: index) else { return }
        self.region = region
        garanteeMainThread {
            self.holidaysListDidChange?(self)
        }
    }
}
extension BankHolidaysViewModel {
    var events: [Event] {
        get {
            guard let bankHoliday else { return [] }
            switch region {
            case .englandAndWales:
                return bankHoliday.englandAndWales.events
            case .northernIreland:
                return bankHoliday.northernIreland.events
            case .scotland:
                return bankHoliday.scotland.events
            }
        }
    }
}

private extension BankHolidaysViewModel {
    func garanteeMainThread(_ work: @escaping () -> Void){
        if Thread.isMainThread {
            work()
        } else {
            dispatchQueue.async(execute: work)
        }
    }
    
}


