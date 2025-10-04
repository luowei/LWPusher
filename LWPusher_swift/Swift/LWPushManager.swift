//
// LWPushManager.swift
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//
// Swift version - Modern implementation

import Foundation
import UIKit
import UserNotifications

// MARK: - Logging

#if DEBUG
func pushLog(_ message: String, function: String = #function, line: Int = #line) {
    print("\(function) [Line \(line)]\n\(message)\n\n")
}
#else
func pushLog(_ message: String, function: String = #function, line: Int = #line) {}
#endif

// MARK: - LWPushManager

@objc public class LWPushManager: NSObject {

    // MARK: - Properties

    @objc public var appID: UInt32
    @objc public var appKey: String

    // MARK: - Singleton

    @objc public static let shared = LWPushManager()

    private override init() {
        // Default configuration for Test App
        self.appID = 2200198799
        self.appKey = "I4511B1BNREA"
        super.init()
    }

    // MARK: - Configuration

    @objc @discardableResult
    public func configure(appID: UInt32, appKey: String) -> Self {
        self.appID = appID
        self.appKey = appKey
        return self
    }

    // MARK: - XGPush Control

    @objc public func startXGPush() {
        guard let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type else {
            pushLog("XGPush class not found")
            return
        }

        guard let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() else {
            pushLog("Failed to get XGPush defaultManager")
            return
        }

        let startSelector = NSSelectorFromString("startXGWithAppID:appKey:delegate:")
        if defaultManager.responds(to: startSelector) {
            let imp = defaultManager.method(for: startSelector)
            typealias StartFunction = @convention(c) (Any, Selector, UInt32, String, Any?) -> Void
            let startFunc = unsafeBitCast(imp, to: StartFunction.self)
            startFunc(defaultManager, startSelector, appID, appKey, self)
        }
    }

    @objc public func stopXGPush() {
        guard let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
              let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() else {
            return
        }

        let stopSelector = NSSelectorFromString("stopXGNotification")
        if defaultManager.responds(to: stopSelector) {
            _ = defaultManager.perform(stopSelector)
        }
    }

    // MARK: - Account Binding

    @objc public func bindAccount(_ account: String) {
        deviceNotificationIsAllowed { [weak self] isAllowed in
            guard let self = self else { return }

            if !isAllowed {
                self.startXGPush()
            } else {
                self.bindAccountInternal(account)
            }
        }
    }

    @objc public func unbindAccount(_ account: String) {
        guard !account.isEmpty else { return }

        guard let tokenManagerClass = NSClassFromString("XGPushTokenManager") as? NSObject.Type,
              let defaultTokenManager = tokenManagerClass.perform(NSSelectorFromString("defaultTokenManager"))?.takeUnretainedValue() else {
            return
        }

        // Set delegate
        defaultTokenManager.setValue(self, forKey: "delegate")

        // Unbind account
        let unbindSelector = NSSelectorFromString("unbindWithIdentifer:type:")
        if defaultTokenManager.responds(to: unbindSelector) {
            let imp = defaultTokenManager.method(for: unbindSelector)
            typealias UnbindFunction = @convention(c) (Any, Selector, String, UInt) -> Void
            let unbindFunc = unsafeBitCast(imp, to: UnbindFunction.self)
            unbindFunc(defaultTokenManager, unbindSelector, account, 1) // XGPushTokenBindTypeAccount = 1
        }
    }

    // MARK: - Push Handling

    @objc public func handlePushInApplicationDidFinishLaunching(options: [UIApplication.LaunchOptionsKey: Any]?) {
        startXGPush()
        setBadgeNumber(0)
    }

    @objc public func handleRemotePushNotification(userInfo: [AnyHashable: Any]) {
        if let urlString = userInfo["url"] as? String,
           let url = URL(string: urlString) {
            openURL(url)
        }
    }

    // MARK: - Badge Management

    @objc public func setBadgeNumber(_ number: Int) {
        guard let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
              let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() else {
            return
        }

        defaultManager.setValue(number, forKey: "xgApplicationBadgeNumber")
    }

    @objc public func getBadgeNumber() -> Int {
        guard let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
              let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue(),
              let badgeNumber = defaultManager.value(forKey: "xgApplicationBadgeNumber") as? Int else {
            return 0
        }
        return badgeNumber
    }

    // MARK: - Private Methods

    private func bindAccountInternal(_ account: String) {
        guard !account.isEmpty else { return }

        guard let tokenManagerClass = NSClassFromString("XGPushTokenManager") as? NSObject.Type,
              let defaultTokenManager = tokenManagerClass.perform(NSSelectorFromString("defaultTokenManager"))?.takeUnretainedValue() else {
            return
        }

        // Set delegate
        defaultTokenManager.setValue(self, forKey: "delegate")

        // Bind account
        let bindSelector = NSSelectorFromString("bindWithIdentifier:type:")
        if defaultTokenManager.responds(to: bindSelector) {
            let imp = defaultTokenManager.method(for: bindSelector)
            typealias BindFunction = @convention(c) (Any, Selector, String, UInt) -> Void
            let bindFunc = unsafeBitCast(imp, to: BindFunction.self)
            bindFunc(defaultTokenManager, bindSelector, account, 1) // XGPushTokenBindTypeAccount = 1
        }
    }

    private func deviceNotificationIsAllowed(handler: @escaping (Bool) -> Void) {
        guard let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
              let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() else {
            handler(false)
            return
        }

        let selector = NSSelectorFromString("deviceNotificationIsAllowed:")
        if defaultManager.responds(to: selector) {
            let imp = defaultManager.method(for: selector)
            typealias AllowedFunction = @convention(c) (Any, Selector, @escaping (Bool) -> Void) -> Void
            let allowedFunc = unsafeBitCast(imp, to: AllowedFunction.self)
            allowedFunc(defaultManager, selector, handler)
        } else {
            handler(false)
        }
    }

    private func openURL(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

@available(iOS 10.0, *)
extension LWPushManager: UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushLog("userNotificationCenter willPresent notification")
        completionHandler([.badge, .sound, .alert])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        pushLog("userNotificationCenter didReceive response")
        completionHandler()
    }

    @available(iOS 12.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      openSettingsFor notification: UNNotification?) {
        pushLog("userNotificationCenter openSettingsFor notification")
    }
}

// MARK: - XGPushDelegate (Dynamic Protocol Conformance)

extension LWPushManager {

    @objc dynamic func xgPushDidReceiveRemoteNotification(_ notification: Any,
                                                          withCompletionHandler completionHandler: ((UInt) -> Void)?) {
        pushLog("xgPushDidReceiveRemoteNotification")
    }

    @available(iOS 10.0, *)
    @objc dynamic func xgPushUserNotificationCenter(_ center: UNUserNotificationCenter,
                                                    willPresent notification: UNNotification,
                                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushLog("xgPushUserNotificationCenter willPresent")

        // Report notification info
        if let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
           let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() {
            let reportSelector = NSSelectorFromString("reportXGNotificationInfo:")
            if defaultManager.responds(to: reportSelector) {
                _ = defaultManager.perform(reportSelector, with: notification.request.content.userInfo)
            }
        }

        completionHandler([.badge, .sound, .alert])
    }

    @available(iOS 10.0, *)
    @objc dynamic func xgPushUserNotificationCenter(_ center: UNUserNotificationCenter,
                                                    didReceive response: UNNotificationResponse,
                                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        pushLog("xgPushUserNotificationCenter didReceive")

        // Report notification response
        if let xgPushClass = NSClassFromString("XGPush") as? NSObject.Type,
           let defaultManager = xgPushClass.perform(NSSelectorFromString("defaultManager"))?.takeUnretainedValue() {
            let reportSelector = NSSelectorFromString("reportXGNotificationResponse:")
            if defaultManager.responds(to: reportSelector) {
                _ = defaultManager.perform(reportSelector, with: response)
            }
        }

        completionHandler()
    }

    @objc dynamic func xgPushDidFinishStart(_ isSuccess: Bool, error: Error?) {
        pushLog("xgPushDidFinishStart: \(isSuccess), error: \(String(describing: error))")
    }

    @objc dynamic func xgPushDidFinishStop(_ isSuccess: Bool, error: Error?) {
        pushLog("xgPushDidFinishStop: \(isSuccess), error: \(String(describing: error))")
    }

    @objc dynamic func xgPushDidReportNotification(_ isSuccess: Bool, error: Error?) {
        pushLog("xgPushDidReportNotification: \(isSuccess), error: \(String(describing: error))")
    }

    @objc dynamic func xgPushDidSetBadge(_ isSuccess: Bool, error: Error?) {
        pushLog("xgPushDidSetBadge: \(isSuccess), error: \(String(describing: error))")
    }

    @objc dynamic func xgPushDidRegisteredDeviceToken(_ deviceToken: String?, error: Error?) {
        pushLog("xgPushDidRegisteredDeviceToken: \(String(describing: deviceToken)), error: \(String(describing: error))")
        if let token = deviceToken {
            pushLog("Device token: \(token)")
        }
    }
}

// MARK: - XGPushTokenManagerDelegate (Dynamic Protocol Conformance)

extension LWPushManager {

    @objc dynamic func xgPushDidBindWithIdentifier(_ identifier: String,
                                                   type: UInt,
                                                   error: Error?) {
        pushLog("xgPushDidBindWithIdentifier: \(identifier), type: \(type), error: \(String(describing: error))")
    }

    @objc dynamic func xgPushDidUnbindWithIdentifier(_ identifier: String,
                                                     type: UInt,
                                                     error: Error?) {
        pushLog("xgPushDidUnbindWithIdentifier: \(identifier), type: \(type), error: \(String(describing: error))")
    }
}
