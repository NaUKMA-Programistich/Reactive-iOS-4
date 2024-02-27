import Foundation

struct Location {
    let latitude: String
    let longitude: String
}

struct ForecastData {
    let city: String
    let elements: [ForecastElement]
}

struct ForecastElement {
    let temp: Double
    let time: String
    let dateByDay: Date?
    let wind: Double
    let weatherName: String
    let weatherIcon: Data
}


struct ForecastDataDto: Codable {
    let list: [ForecastElementDto]
    let city: CityForecastDataDto
    
    var icons: [String] {
        var result: [String] = []
        list.forEach { $0.weather.forEach { data in result.append(data.icon) } }
        return result
    }
}

struct ForecastElementDto: Codable {
    let main: ForecastMainDto
    let wind: ForecastWindDto
    let clouds: ForecastCloudDto
    let weather: [ForecastWeatherDto]
    let dt: Date
    
    var dateByDay: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self.dt)
        return calendar.date(from: components)
    }
    
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self.dt)
    }
    
    var normalTemp: Double {
        (self.main.temp - 273.15).rounded(2)
    }
}

struct ForecastMainDto: Codable {
    let temp: Double
    let humidity: Int

}

struct ForecastWindDto: Codable {
    let speed: Double
    let deg: Double
}

struct ForecastCloudDto: Codable {
    let all: Int
}

struct ForecastWeatherDto: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CityForecastDataDto: Codable {
    let name: String
}

extension Double {
    func rounded(_ places: Double) -> Double {
        let divisor = pow(10.0, places)
        return (self * divisor).rounded() / divisor
    }
}
