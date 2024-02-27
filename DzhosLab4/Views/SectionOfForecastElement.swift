import Foundation
import RxDataSources

struct SectionOfForecastElement {
    var header: String
    var items: [Item]
}

extension Array where Element == ForecastElement {
    func convertToSection() -> [SectionOfForecastElement] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy, MMMM dd"
        
        var elementByDate = [Date: [ForecastElement]]()

        for item in self {
            guard let date = item.dateByDay else { continue }
            elementByDate[date, default: []].append(item)
        }
        
        return elementByDate.map { key, elements in
            let header = formatter.string(from: key)
            return SectionOfForecastElement(header: header, items: elements)
        }.sorted { $0.header < $1.header }
    }
}

extension SectionOfForecastElement: SectionModelType {
    typealias Item = ForecastElement

    init(original: SectionOfForecastElement, items: [Item]) {
        self = original
        self.items = items
    }
}
