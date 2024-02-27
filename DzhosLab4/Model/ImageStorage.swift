import Foundation

class ImageStorage {
    static let shared: ImageStorage = .init()
    
    private var database: [String: Data] = [:]
    
    func put(key: String, value: Data) {
        if isExist(key: key) { return }
        
        database[key] = value
    }
    
    func get(key: String) -> Data? {
        return database[key]
    }
    
    func isExist(key: String) -> Bool {
        return database[key] != nil
    }
}
