import XCTest
@testable import DzhosLab4
import RxSwift
import RxBlocking
import RxTest

final class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!

    override func setUp() {
        super.setUp()
        self.weatherService = WeatherService()
    }
    
    /**
     Test sucess getting image by icon
     https://openweathermap.org/weather-conditions
     */
    func testGetSuccessRainImage() throws {
        let expectedIcon = "10d"
        let expectedDataCount = Optional.some(2584)
        
        let blocking = try? weatherService
            .getImage(icon: expectedIcon)
            .asObservable()
            .toBlocking()
            .first()
        
        let actualIcon = blocking?.0
        let actualDataCount = blocking?.1.count

        XCTAssertEqual(expectedIcon, actualIcon)
        XCTAssertEqual(expectedDataCount, actualDataCount)
    }
    
    /**
     Test error getting image by wrong icon
     https://openweathermap.org/weather-conditions
     */
    func testGetFailureImage() throws {
        let expectedIcon = "foo"
        
        let blocking = try? weatherService
            .getImage(icon: expectedIcon)
            .asObservable()
            .toBlocking()
            .first()

        XCTAssertNil(blocking)
    }
    
    /**
     Test sucess geolocation by 760 Capitol Avenue, Frankfort, KY 40601, United States of America
     */
    func testSucessGetGeoLocation() throws {
        let query = "Ky"
        let expectedLatitude = "38.1888999"
        let expectedLongitude = "-84.8753"
        
        let blocking = try? weatherService
            .getCoordinate(query: query)
            .asObservable()
            .toBlocking()
            .first()
        
        let actualLatitude = blocking?.latitude
        let actualLongitude = blocking?.longitude
        
        XCTAssertEqual(expectedLatitude, actualLatitude)
        XCTAssertEqual(expectedLongitude, actualLongitude)
    }
    
    /**
     Test error geocoder by undefines symbol
     */
    func testGetFailureGetGeoLocation() throws {
        let query = "aclajfja2882"

        let blocking = try? weatherService
            .getCoordinate(query: query)
            .asObservable()
            .toBlocking()
            .first()

        XCTAssertNil(blocking)
    }
    
    /**
     Test weather in Kyiv
     */
    func testGetWeatherKyiv() throws {
        let expectedQuery = "Kyiv"
        
        let blocking = try? weatherService
            .getWeather(query: expectedQuery)
            .asObservable()
            .toBlocking()
            .first()
        
        let actualCity = blocking?.city
        let actualDtos = blocking?.elements
        
        XCTAssertEqual(expectedQuery, actualCity)
        XCTAssertTrue(((actualDtos?.isEmpty) != nil))
    }
    
    /**
     Test coordinate
     **/
    func testGetForecastByCoordinates() throws {
        let expectedLatitude = "38.1888999"
        let expectedLongitude = "-84.8753"
        
        let actualDtos = try? weatherService
            .getForecast(lat: expectedLatitude, lon: expectedLongitude)
            .asObservable()
            .toBlocking()
            .first()
        
        XCTAssertNotNil(actualDtos)
    }
    
    override func tearDown() {
        weatherService = nil
        super.tearDown()
    }
}
