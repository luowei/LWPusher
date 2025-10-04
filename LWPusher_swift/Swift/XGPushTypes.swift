//
// XGPushTypes.swift
// Swift type definitions for XGPush SDK
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//

import Foundation

// MARK: - XGPush Token Bind Type

/// Device token binding types for targeted push notifications
@objc public enum XGPushTokenBindType: UInt {
    /// Token not bound to any type (deprecated in 3.2.0+)
    case none = 0
    /// Token bound to account for account-based push
    case account = 1
    /// Token bound to tag for tag-based push
    case tag = 2
}

// MARK: - Notification Action Options

/// Notification action button configuration options
@objc public enum XGNotificationActionOptions: UInt {
    /// No special options
    case none = 0
    /// Requires authentication
    case authenticationRequired = 1
    /// Destructive action
    case destructive = 2
    /// Opens app in foreground
    case foreground = 4
}

// MARK: - Notification Category Options

/// Notification category configuration options
@objc public enum XGNotificationCategoryOptions: UInt {
    /// No special options
    case none = 0
    /// Send dismiss event to UNUserNotificationCenter (iOS 10+)
    case customDismissAction = 1
    /// Allow display in CarPlay
    case allowInCarPlay = 2
}

// MARK: - User Notification Types

/// Push notification types supported by the app
@objc public struct XGUserNotificationTypes: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// No notifications
    public static let none = XGUserNotificationTypes(rawValue: 0)
    /// Badge support
    public static let badge = XGUserNotificationTypes(rawValue: 1 << 0)
    /// Sound support
    public static let sound = XGUserNotificationTypes(rawValue: 1 << 1)
    /// Alert support
    public static let alert = XGUserNotificationTypes(rawValue: 1 << 2)
    /// CarPlay support (iOS 10.0+)
    public static let carPlay = XGUserNotificationTypes(rawValue: 1 << 3)
    /// Critical alert (iOS 12.0+)
    public static let criticalAlert = XGUserNotificationTypes(rawValue: 1 << 4)
    /// Provides app notification settings (iOS 12.0+)
    public static let providesAppNotificationSettings = XGUserNotificationTypes(rawValue: 1 << 5)
    /// Provisional notifications (iOS 12.0+)
    public static let provisional = XGUserNotificationTypes(rawValue: 1 << 6)

    /// All standard notification types (badge, sound, alert)
    public static let all: XGUserNotificationTypes = [.badge, .sound, .alert]
}

// MARK: - Swift-friendly Push Configuration

/// Swift-friendly configuration for push notifications
@objc public class LWPushConfiguration: NSObject {

    /// App ID from XGPush console
    public let appID: UInt32

    /// App Key from XGPush console
    public let appKey: String

    /// Enable debug logging
    public var enableDebug: Bool = false

    /// Notification types to register
    public var notificationTypes: XGUserNotificationTypes = .all

    public init(appID: UInt32, appKey: String) {
        self.appID = appID
        self.appKey = appKey
        super.init()
    }

    /// Convenience initializer with debug flag
    public convenience init(appID: UInt32, appKey: String, enableDebug: Bool) {
        self.init(appID: appID, appKey: appKey)
        self.enableDebug = enableDebug
    }
}

// MARK: - Push Notification Result

/// Result type for push operations
public enum LWPushResult {
    case success
    case failure(Error)

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - Push Notification Info

/// Swift-friendly push notification information
@objc public class LWPushNotificationInfo: NSObject {

    /// Raw user info dictionary
    public let userInfo: [AnyHashable: Any]

    /// URL from notification if present
    public var url: URL? {
        guard let urlString = userInfo["url"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }

    /// Title from notification if present
    public var title: String? {
        return userInfo["aps"] as? [String: Any] |> { $0?["alert"] as? [String: Any] } |> { $0?["title"] as? String }
    }

    /// Body from notification if present
    public var body: String? {
        return userInfo["aps"] as? [String: Any] |> { $0?["alert"] as? [String: Any] } |> { $0?["body"] as? String }
    }

    /// Badge number from notification if present
    public var badge: Int? {
        return userInfo["aps"] as? [String: Any] |> { $0?["badge"] as? Int }
    }

    public init(userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        super.init()
    }
}

// MARK: - Custom Operators (Internal)

infix operator |>: MultiplicationPrecedence

@inline(__always)
private func |> <T, U>(value: T?, transform: (T) -> U?) -> U? {
    guard let value = value else { return nil }
    return transform(value)
}
