
import Foundation

public final class FileCache {
    public private(set) var items = [String: TodoItem]()
    
    public func add(item: TodoItem) {
        items[item.id] = item
    }
    
    @discardableResult
    public func remove(id: String) -> TodoItem? {
        let deleted = items[id]
        items[id] = nil
        return deleted
    }
    
    //json
    public func saveToJson(toFileWithID file: String) throws {
        let arrayItems = items.map { $0.value }
        try saveItemsJson(items: arrayItems, to: file)
    }
    
    func saveItemsJson(items: [TodoItem], to file: String) throws {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchSystemDirectory
        }
        
        let path = directory.appendingPathComponent("\(file).json")
        let itemsJson = items.map { $0.json }
        let data = try JSONSerialization.data(withJSONObject: itemsJson, options: [])
        try data.write(to: path, options: .atomic)
    }
    
    public func loadFromJson(from file: String) throws {
        self.items = try loadItemsJson(from: file).reduce(into: [:]) { result, item in
            result[item.id] = item
        }
    }
    
    private func loadItemsJson(from file: String) throws -> [TodoItem] {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchSystemDirectory
        }
        
        let path = directory.appendingPathComponent("\(file).json")
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = json as? [Any] else {
            throw FileCacheErrors.unparsableData
        }
        let todoItems = json.compactMap { TodoItem.parse(json: $0) }
        return todoItems
    }
    
    
    //csv
    public func saveToCSV(toFileWithID file: String) throws {
        let arrayItems = items.map { $0.value }
        try saveItemsCSV(items: arrayItems, to: file)
    }
    
    private func saveItemsCSV(items: [TodoItem], to file: String) throws {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchSystemDirectory
        }
        print(directory)
        let path = directory.appendingPathComponent("\(file).csv")
        let header = "id,text,importance,deadline,done,dateCreation,dateChanging"
        let csvLines = [header] + items.map { $0.csv }
        guard let data = csvLines.joined(separator: "\n").data(using: .utf8) else {
            throw FileCacheErrors.UTF8FormatError
        }
        try data.write(to: path, options: .atomic)
    }
    
    
    public func loadFromCSV(from file: String) throws {
        self.items = try loadItemsCSV(from: file).reduce(into: [:]) { result, item in
            result[item.id] = item
        }
    }
    
    private func loadItemsCSV(from file: String) throws -> [TodoItem] {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchSystemDirectory
        }
        
        let path = directory.appendingPathComponent("\(file).csv")
        let fileData = try Data(contentsOf: path)
        
        guard let csvString = String(data: fileData, encoding: .utf8) else {
            throw FileCacheErrors.UTF8FormatError
        }
        let csvLines = csvString.components(separatedBy: "\n")
        let todoItems = csvLines.compactMap { TodoItem.parse(csv: $0) }
        return todoItems
    }
}



public enum FileCacheErrors: Error {
    case noSuchSystemDirectory
    case unparsableData
    case UTF8FormatError
}

extension FileCacheErrors: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noSuchSystemDirectory:
            return "Указанная системная дирректория отсутсвует"
        case .unparsableData:
            return "Невозможно распарсить данные"
        case .UTF8FormatError:
            return "Ошибка форматирования UTF-8"
        }
    }
}

