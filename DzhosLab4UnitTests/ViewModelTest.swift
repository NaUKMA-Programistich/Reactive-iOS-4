import XCTest
@testable import DzhosLab4
import RxSwift
import RxBlocking
import RxTest

final class ViewModelTest: XCTestCase {

    var viewModel: ViewModel!
    var scheduler: TestScheduler!
    var disposable: Disposable!

    override func setUp() {
        super.setUp()
        self.viewModel = ViewModel()
        self.scheduler = TestScheduler(initialClock: 0)
    }
    
    /**
     Test empty query action
     */
    func testEmptyQuery() throws {
        let dataObserver = scheduler.createObserver([ForecastElement].self)

        scheduler.scheduleAt(0) {
            self.disposable = self.viewModel.data.subscribe(dataObserver)
        }
        viewModel.action.accept("")
        
        scheduler.start()
        
        let results = dataObserver.events.map { $0.value.element! }
        XCTAssertTrue(results.isEmpty)
    }
    
    /**
     Test query when action not isloading
     */
    func testLoadingProcess() throws {
        let isLoadingObserver = scheduler.createObserver(Bool.self)
        
        scheduler.scheduleAt(0) {
            self.disposable = self.viewModel.isLoading.subscribe(isLoadingObserver)
        }
        viewModel.action.accept("Kyiv")
        scheduler.start()
        
        let results = isLoadingObserver.events.map { $0.value.element! }
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first!)
    }
    
    /**
     Test query when action already loading
     */
    func testAlreadyLoadingProcess() throws {
        let isLoadingObserver = scheduler.createObserver(Bool.self)
        
        scheduler.scheduleAt(0) {
            self.disposable = self.viewModel.isLoading.subscribe(isLoadingObserver)
        }
        viewModel.action.accept("Kyiv")
        viewModel.action.accept("Lviv")
        scheduler.start()
        
        let results = isLoadingObserver.events.map { $0.value.element! }
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first!)
    }
   
// IDK whats wrong
//    func testSuccessActionQuery() throws {
//        let dataObserver = scheduler.createObserver([ForecastElement].self)
//
//        scheduler.scheduleAt(0) {
//            self.disposable = self.viewModel
//                .data
//                .asObservable()
//                .delay(.seconds(5), scheduler: self.scheduler)
//                .bind(to: dataObserver)
//            
//        }
//        viewModel.action.accept("Kyiv")
//        scheduler.start()
//
//        
//        let results = dataObserver.events.map { $0.value.element! }
//        XCTAssertFalse(results.isEmpty)
//    }
    
    override func tearDown() {
        scheduler.scheduleAt(1000) {
            self.disposable.dispose()
        }
        super.tearDown()
    }
}
