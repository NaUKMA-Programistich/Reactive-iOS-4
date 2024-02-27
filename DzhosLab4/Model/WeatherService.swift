import Foundation
import RxSwift
import Logging
import CoreLocation

private let apiKey = ""

class WeatherService {
    static let shared = WeatherService()
    
    private let logger = Logger(label: "WeatherService")
    
    enum WeatherError: Error {
        case simpleError
    }
    
    func getWeather(query: String) -> Single<ForecastData> {
        return getCoordinate(query: query)
            .flatMap { coordinate -> Single<ForecastData> in
                self.getForecast(
                    lat: coordinate.latitude,
                    lon: coordinate.longitude
                ).flatMap { forecastDataDto in
                    self.getImages(icons: forecastDataDto.icons).map { images in
                        var elements: [ForecastElement] = []
                        for item in forecastDataDto.list {
                            let weatherName = item.weather.first?.main ?? "None"
                            let weatherIconName = item.weather.first?.icon ?? "None"
                            let weatherIcon = images[weatherIconName] ?? Data()
                            
                            let element = ForecastElement(
                                temp: item.normalTemp,
                                time: item.time,
                                dateByDay: item.dateByDay,
                                wind: item.wind.speed,
                                weatherName: weatherName,
                                weatherIcon: weatherIcon
                            )
                            elements.append(element)
                        }
                        
                        return ForecastData(
                            city: forecastDataDto.city.name,
                            elements: elements
                        )
                    }
                }
            }
    }
    
    func getForecast(lat: String, lon: String) -> Single<ForecastDataDto> {
        let url = "http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=88226749fcbbf29cb5d31cb7e7efc1e1"
        logger.info("#getForecast url \(url)")
        
        return Single<ForecastDataDto>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    self.logger.error("#getForecast by \(url) \(error)")
                    single(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self.logger.error("#getForecast single data error")
                    single(.failure(WeatherError.simpleError))
                    return
                }
                self.logger.info("#getForecast we have data \(data)")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                guard
                    let forecastData = try? decoder.decode(ForecastDataDto.self, from: data)
                else {
                    self.logger.error("#getForecast decode error")
                    single(.failure(WeatherError.simpleError))
                    return
                }

                self.logger.info("#getForecast we have forecast data")
                single(.success(forecastData))
                return
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    func getCoordinate(query: String) -> Single<Location> {
        let geocoder = CLGeocoder()
        
        return Single<Location>.create { single in
            geocoder.geocodeAddressString(query) { (placemarks, error) in
                if error != nil {
                    self.logger.error("#getCoordinate single error geocode")
                    single(.failure(WeatherError.simpleError))
                    return
                }
                
                guard
                    let placemark = placemarks?.first,
                    let location = placemark.location
                else {
                    self.logger.error("#getCoordinate single placemark or location")
                    single(.failure(WeatherError.simpleError))
                    return
                }
                
                let latitude = String(location.coordinate.latitude)
                let longitude = String(location.coordinate.longitude)
                
                
                let coordinate = Location(latitude: latitude, longitude: longitude)
                single(.success(coordinate))
            }
            return Disposables.create { geocoder.cancelGeocode() }
        }
    }
    
    private func getImages(icons: [String]) -> Single<Dictionary<String, Data>> {
        let imageRequests = icons.map { getImage(icon: $0) }
        
        return Single.zip(imageRequests)
            .map { dataArray in
                var imagesDictionary = [String: Data]()
                for (icon, data) in dataArray {
                    imagesDictionary[icon] = data
                }
                return imagesDictionary
            }
    }

    
    func getImage(icon: String) -> Single<(String, Data)> {
        return Single<(String, Data)>.create { single in
            let url = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
                if let error = error {
                    self.logger.error("#getImage by \(url) \(error)")
                    single(.failure(error))
                    return
                }
                
                if
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode != 200
                {
                    self.logger.error("#getImage by code \(httpResponse.statusCode)")
                    single(.failure(WeatherError.simpleError))
                    return
                }
                
                guard let data = data else {
                    self.logger.error("#getImage single data error")
                    single(.failure(WeatherError.simpleError))
                    return
                }
                single(.success((icon, data)))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
