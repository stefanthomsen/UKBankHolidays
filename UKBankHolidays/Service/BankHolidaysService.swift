import Foundation

protocol BankHolidaysServiceProtocol: AnyObject {
    func fetchBankHolidays(completion: @escaping (Result<BankHoliday, Error>) -> Void)
}

class BankHolidaysService: BankHolidaysServiceProtocol {
    
    let url = URL(string: "https://www.gov.uk/bank-holidays.json")!
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchBankHolidays(completion: @escaping (Result<BankHoliday, Error>) -> Void) {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let bankHoliday = try JSONDecoder().decode(BankHoliday.self, from: data)
                completion(.success(bankHoliday))
            } catch {
                print(error)
            }
        }.resume()
    }
}
