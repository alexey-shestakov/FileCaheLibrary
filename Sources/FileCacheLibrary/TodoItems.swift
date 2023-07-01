//
//  File.swift
//  
//
//  Created by Alexey Shestakov on 01.07.2023.
//
import Foundation

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadline: Date?
    public let done: Bool
    public let dateCreation: Date
    public let dateChanging: Date?
    
    public init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, done: Bool = false, dateCreation: Date, dateChanging: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.dateCreation = dateCreation
        self.dateChanging = dateChanging
    }
}

public enum Importance: String {
    case unimportant = "неважная"
    case normal = "обычная"
    case important = "важная"
}


public extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        
        guard let dictionary = json as? [String: Any],
              let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let dateCreationInt = dictionary["dateCreation"] as? Int else { return nil }
        
        
        let done = (dictionary["done"] as? Bool) ?? false
        let dateCreation = Date(timeIntervalSince1970: TimeInterval(dateCreationInt))
        
        var importance: Importance = .normal
        if let importanceRawValue = dictionary["importance"] as? String {
            importance = Importance(rawValue: importanceRawValue) ?? .normal
        }
        
        var deadline: Date?
        if let deadlineInt = dictionary["deadline"] as? Int {
            deadline = Date(timeIntervalSince1970: TimeInterval(deadlineInt))
        }
        
        var dateChanging: Date?
        if let dateChangingInt = dictionary["dateChanging"] as? Int {
            dateChanging = Date(timeIntervalSince1970: TimeInterval(dateChangingInt))
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, dateCreation: dateCreation, dateChanging: dateChanging)
    }
    
    var json: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "dateCreation": Int(dateCreation.timeIntervalSince1970),
        ]
        
        if importance != .normal {
            dictionary["importance"] = importance.rawValue
        }
        
        if let deadline = deadline {
            dictionary["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        
        if let dateChanging = dateChanging {
            dictionary["dateChanging"] = Int(dateChanging.timeIntervalSince1970)
        }
        return dictionary
    }
}

extension TodoItem {
    public static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: ",")
        
        guard components.count == 7 else {
            return nil // Всего 7 полей, которые должны существовать(пусть даже и пустые)
        }
        
        let id = components[0]
        let text = components[1]
        let importanceRawValue = components[2]
        let importance = Importance(rawValue: importanceRawValue) ?? .normal
        
        var deadline: Date?
        let deadlineString = components[3]
        if !deadlineString.isEmpty {
            deadline = Date(timeIntervalSince1970: TimeInterval(deadlineString) ?? 0)
        }
        
        let done = components[4] == "1"
        
        var dateCreation = Date()
        let dateCreationString = components[5]
        if !dateCreationString.isEmpty {
            // Выходим из метода, чтобы не читать header
            guard let timeinterval = TimeInterval(dateCreationString) else {return nil}
            dateCreation = Date(timeIntervalSince1970: timeinterval)
        }
        
        var dateChanging: Date?
        let dateChangingString = components[6]
        if !dateChangingString.isEmpty {
            dateChanging = Date(timeIntervalSince1970: TimeInterval(dateChangingString) ?? 0)
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, dateCreation: dateCreation, dateChanging: dateChanging)
    }
    
    public var csv: String {
        var csvString = ""
        csvString += "\(id),"
        csvString += "\(text),"
        csvString += importance != .normal ? "\(importance.rawValue)," : ","
        csvString += deadline != nil ? "\(deadline!.timeIntervalSince1970)," : ","
        csvString += done ? "1," : "0,"
        csvString += "\(dateCreation.timeIntervalSince1970),"
        csvString += dateChanging != nil ? "\(dateChanging!.timeIntervalSince1970)" : ""
        
        return csvString
    }
}
