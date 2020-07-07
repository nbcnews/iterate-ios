//
//  Embed.swift
//  Iterate
//
//  Created by Michael Singleton on 12/30/19.
//  Copyright © 2020 Pickaxe LLC. (DBA Iterate). All rights reserved.
//

import Foundation

/// Represents the context of the request to the embed endpoint. This includes
/// things like device type, user traits, and targeting options.
struct EmbedContext: Codable {
    var app: AppContext?
    var event: EventContext?
    var targeting: TargetingContext?
    var trigger: TriggerContext?
    var type: EmbedType?
    var userTraits: UserProperties?
}

// MARK: App

// Contains data about the application
struct AppContext: Codable {
    var urlScheme: String?
    var version: String?
}

// MARK: Event

/// Contains event data
struct EventContext: Codable {
    var name: String?
}

// MARK: Targeting

/// Contains targeting options that are overridden by the client
struct TargetingContext: Codable {
    var frequency: TargetingContextFrequency?
    var surveyId: String?
}

/// Targeting content frequecy options. e.g. 'Always' is used to force
/// a survey to be shown regardless of other targeting options set on
/// the server
enum TargetingContextFrequency: String, Codable {
    case always = "always"
}

// MARK: Triggering

/// Contains triggering options (e.g. indicate a survey was 'manually' triggered)
struct TriggerContext: Codable {
    var surveyId: String?
    var type: TriggerType?
}

/// Trigger types, currently the only option is manually triggered
enum TriggerType: String, Codable {
    case manual = "manual"
}

// MARK: Type

enum EmbedType: String, Codable {
    case mobile = "mobile"
    case web = "web"
}

// MARK: Properties

public typealias UserProperties = [String: UserPropertyValue]
public typealias ResponseProperties = [String: ResponsePropertyValue]

/// User property values can be a string, int, or bool
public struct UserPropertyValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "UserPropertyValue value cannot be decoded")
        }
    }

    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

public struct ResponsePropertyValue {
    let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    /// Returns a string representing the type of the value, this is used
    /// when passing the value into the survey webview as a
    /// query parameter
    public func typeString() -> String {
        switch value {
        case _ as Bool:
            return "_boolean"
        case _ as Int:
            return "_number"
        default:
            return ""
        }
    }
}
