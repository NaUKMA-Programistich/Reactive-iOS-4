import Logging
import RxSwift
import RxRelay
import UIKit

final class ViewModel {
    private let logger = Logger(label: "ViewModel")
    private let dBagVM = DisposeBag()
    private let weatherService: WeatherService = .shared
    
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    private(set) lazy var isLoading = _isLoading.asObservable()

    private var _query = BehaviorRelay<String>(value: "")
    private(set) lazy var query = _query.asObservable()
    
    private var _data = PublishRelay<Array<ForecastElement>>()
    private(set) lazy var data = _data.asObservable()
    
    public let action = PublishRelay<String>()
    
    init() {
        action
            .subscribe(onNext: onActionChange)
            .disposed(by: dBagVM)
    }
    
    func onActionChange(query: String) {
        logger.info("#onActionChange \(query)")
        if query.isEmpty {
            logger.info("#onActionChange empty")
            _query.accept("")
            _data.accept([])
            return
        }
        
        if _isLoading.value {
            logger.info("#onActionChange in progress")
            return
        }
        
        if query == _query.value {
            logger.info("#onActionChange same query")
            return
        }
        
        _isLoading.accept(true)
        weatherService
            .getWeather(query: query)
            .subscribe(
                onSuccess: { [weak self] data in
                    self?._query.accept(data.city)
                    self?._data.accept(data.elements)
                    self?._isLoading.accept(false)
                },
                onFailure: { [weak self] error in
                    self?.logger.error("Error \(error)")
                    self?._query.accept("Error")
                    self?._data.accept([])
                    self?._isLoading.accept(false)
                }
            )
            .disposed(by: dBagVM)
    }
}
