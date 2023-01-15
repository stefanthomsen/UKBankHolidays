import UIKit

class BankHolidaysViewController: UIViewController {
    
    var viewModel: BankHolidaysViewModelProtocol
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.backgroundColor = .clear
        return segmentedControl
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HolidayTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    init(viewModel: BankHolidaysViewModelProtocol = BankHolidaysViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubViews()
        configConstraints()
        configSegmentControl()
        configNavigationBarApparence()
        viewModel.fetchBankHolidays()
        viewModel.holidaysListDidChange = { [weak self] viewModel in
            guard let `self` = self else { return }
            switch viewModel.viewStatus {
            case .loading:
                self.loading()
            case .loaded:
                self.loaded()
            case .failed:
                // TODO: show error
                break
            }
        }
    }
    
    @objc func handleSegmentChanged(_ sender: UISegmentedControl) {
        viewModel.didSelectSegmentControl(index: sender.selectedSegmentIndex)
    }
}

// MARK: Handle View Status
private extension BankHolidaysViewController {
    
    func loading() {
        self.tableView.isHidden = true
    }
    
    func loaded() {
        self.tableView.isHidden = false
        self.tableView.reloadData()
        self.segmentedControl.selectedSegmentIndex = viewModel.region.rawValue
    }
    
    func failed(error: Error) {
        // TODO: show error
    }
}

// MARK: View Config
private extension BankHolidaysViewController {
    
    func configNavigationBarApparence() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func configSubViews() {
        self.title = "Uk Bank Holidays"
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(segmentedControl)
    }
    
    func configConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 6),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configSegmentControl(selectedRegion: BankHolidaysViewModel.Region = .englandAndWales) {
        for (index, item) in BankHolidaysViewModel.Region.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: item.title, at: index, animated: false)
        }
        segmentedControl.addTarget(self, action: #selector(handleSegmentChanged), for: .valueChanged)
    }
}

// MARK: UITableView - Data Source | Delegate
extension BankHolidaysViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HolidayTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = viewModel.events[indexPath.row].title
        cell.detailTextLabel?.text = viewModel.events[indexPath.row].date
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: UIToolbarDelegate
extension BankHolidaysViewController: UIToolbarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}
