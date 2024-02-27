import Logging
import RxSwift
import UIKit
import RxDataSources

final class ViewController: UIViewController {
    private var viewModel = ViewModel()
    private let dBagVC = DisposeBag()
    
    private let tableCell = "tableCell"
    private let headerCell = "headerCell"
    private let logger = Logger(label: "ViewController")

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("#viewDidLoad")
        
        view.addSubview(buildView)
        setupConstraints()
        logger.info("#viewDidLoad setup view")
        
        queryView.rx.text
            .orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .bind(to: viewModel.action)
            .disposed(by: dBagVC)
        
        viewModel
            .query
            .map { "Weather forecast for: \($0)" }
            .bind(to: self.textView.rx.text)
            .disposed(by: dBagVC)
        
        viewModel
            .isLoading
            .observe(on: MainScheduler.instance)
            .bind { [weak self] flag in
                self?.loadingView.isHidden = !flag
                self?.stateView.isHidden = flag
            }
            .disposed(by: dBagVC)
        
        let dataSource = createDataSource()

        viewModel
            .data
            .map { $0.convertToSection() }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: dBagVC)
    }
    
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfForecastElement> {
        let dataSource =  RxTableViewSectionedReloadDataSource<SectionOfForecastElement>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: self.tableCell,
                    for: indexPath
                ) as! TableViewCell
                cell.configure(element: item)
                return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        return dataSource
    }
    
    private lazy var queryView: UITextField = {
        let queryView = UITextField()
        queryView.backgroundColor = .lightGray
        queryView.placeholder = "Press City"
        
        queryView.translatesAutoresizingMaskIntoConstraints = false
        return queryView
    }()
    
    private lazy var textView: UILabel = {
        let textView = UILabel()
        textView.backgroundColor = .darkGray
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .lightGray
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: tableCell)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stateView: UIView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(tableView)
        
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingView: UIContentUnavailableView = {
        let config = UIContentUnavailableConfiguration.loading()
        let view = UIContentUnavailableView(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
 
    private lazy var buildView: UIView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(queryView)
        stackView.addArrangedSubview(stateView)
        stackView.addArrangedSubview(loadingView)
        
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
   
    private func setupConstraints() {
        view.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            buildView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buildView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            buildView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buildView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buildView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buildView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            queryView.heightAnchor.constraint(equalToConstant: 50),
            textView.heightAnchor.constraint(equalToConstant: 50),
            
            loadingView.trailingAnchor.constraint(equalTo: stateView.trailingAnchor),
            loadingView.leadingAnchor.constraint(equalTo: stateView.leadingAnchor),
            loadingView.topAnchor.constraint(equalTo: stateView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: stateView.bottomAnchor),
        ])
    }
}

#Preview {
    return ViewController()
}
