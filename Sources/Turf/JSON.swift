import Foundation

public enum JSONValue: Hashable, Sendable {
    case array(_ values: JSONArray)
    case object(_ properties: JSONObject)
    
    public init(_ values: JSONArray) {
        self = .array(values)
    }
    
    public init(_ properties: JSONObject) {
        self = .object(properties)
    }
}

extension JSONValue {
    public var array: JSONArray? {
        if case let .array(value) = self {
            return value
        }
        return nil
    }
    
    public var object: JSONObject? {
        if case let .object(value) = self {
            return value
        }
        return nil
    }
}

extension JSONValue: RawRepresentable {
    public typealias RawValue = Any
    
    public init?(rawValue: Any) {
        if let rawArray = rawValue as? JSONArray.TurfRawValue,
                  let array = JSONArray(turfRawValue: rawArray) {
            self = .array(array)
        } else if let rawObject = rawValue as? JSONObject.TurfRawValue,
                  let object = JSONObject(turfRawValue: rawObject) {
            self = .object(object)
        } else {
            return nil
        }
    }
    
    public var rawValue: Any {
        switch self {
        case let .object(value):
            return value.turfRawValue
        case let .array(value):
            return value.turfRawValue
        }
    }
}

public typealias JSONArray = [JSONValue?]

extension JSONArray {
    public typealias TurfRawValue = [Any?]

    public init?(turfRawValue values: TurfRawValue) {
        self = values.map(JSONValue.init(rawValue:))
    }

    public var turfRawValue: TurfRawValue {
        return map { $0?.rawValue }
    }
}

public typealias JSONObject = [String: JSONValue?]

extension JSONObject {
    public typealias TurfRawValue = [String: Any?]
    
    public init?(turfRawValue: TurfRawValue) {
        self = turfRawValue.mapValues { $0.flatMap(JSONValue.init(rawValue:)) }
    }
    
    public var turfRawValue: TurfRawValue {
        return mapValues { $0?.rawValue }
    }
}


extension JSONValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = JSONValue?
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .init(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = JSONValue?
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self = .init(.init(uniqueKeysWithValues: elements))
    }
}

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let object = try? container.decode(JSONObject.self) {
            self = .object(object)
        } else if let array = try? container.decode(JSONArray.self) {
            self = .array(array)
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode as a JSONValue."))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .object(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        }
    }
}
