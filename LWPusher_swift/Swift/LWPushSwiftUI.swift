//
// LWPushSwiftUI.swift
// SwiftUI integration for LWPusher
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Push Notification State

/// Observable state for push notifications
@available(iOS 13.0, *)
public class LWPushState: ObservableObject {

    /// Whether push notifications are enabled
    @Published public var isEnabled: Bool = false

    /// Device token string
    @Published public var deviceToken: String?

    /// Current badge number
    @Published public var badgeNumber: Int = 0

    /// Latest notification received
    @Published public var latestNotification: LWPushNotificationInfo?

    /// Bound accounts
    @Published public var boundAccounts: Set<String> = []

    public init() {}

    /// Check notification authorization status
    public func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    /// Update badge number
    public func updateBadge(_ number: Int) {
        DispatchQueue.main.async {
            self.badgeNumber = number
        }
    }

    /// Add bound account
    public func addBoundAccount(_ account: String) {
        DispatchQueue.main.async {
            self.boundAccounts.insert(account)
        }
    }

    /// Remove bound account
    public func removeBoundAccount(_ account: String) {
        DispatchQueue.main.async {
            self.boundAccounts.remove(account)
        }
    }
}

// MARK: - Push Service

/// SwiftUI-friendly push notification service
@available(iOS 13.0, *)
public class LWPushService: ObservableObject {

    /// Shared instance
    public static let shared = LWPushService()

    /// Push state
    @Published public var state = LWPushState()

    /// Underlying push manager
    private let manager = LWPushManager.shared

    private init() {}

    /// Configure push service
    public func configure(appID: UInt32, appKey: String) {
        manager.configure(appID: appID, appKey: appKey)
    }

    /// Start push service
    public func start() {
        manager.startXGPush()
        state.checkAuthorizationStatus()
    }

    /// Stop push service
    public func stop() {
        manager.stopXGPush()
    }

    /// Bind account
    public func bind(account: String) {
        manager.bindAccount(account)
        state.addBoundAccount(account)
    }

    /// Unbind account
    public func unbind(account: String) {
        manager.unbindAccount(account)
        state.removeBoundAccount(account)
    }

    /// Set badge number
    public func setBadge(_ number: Int) {
        manager.setBadgeNumber(number)
        state.updateBadge(number)
    }

    /// Get badge number
    public func getBadge() -> Int {
        return manager.getBadgeNumber()
    }

    /// Handle remote notification
    public func handleNotification(userInfo: [AnyHashable: Any]) {
        manager.handleRemotePushNotification(userInfo: userInfo)
        let notificationInfo = LWPushNotificationInfo(userInfo: userInfo)
        DispatchQueue.main.async {
            self.state.latestNotification = notificationInfo
        }
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, *)
extension View {

    /// Setup push notifications when view appears
    public func setupPushNotifications(appID: UInt32, appKey: String) -> some View {
        self.onAppear {
            LWPushService.shared.configure(appID: appID, appKey: appKey)
            LWPushService.shared.start()
        }
    }

    /// Bind push account when view appears
    public func bindPushAccount(_ account: String) -> some View {
        self.onAppear {
            LWPushService.shared.bind(account: account)
        }
        .onDisappear {
            LWPushService.shared.unbind(account: account)
        }
    }

    /// Handle push notification taps
    public func onPushNotificationTap(perform action: @escaping (LWPushNotificationInfo) -> Void) -> some View {
        self.onReceive(LWPushService.shared.state.$latestNotification) { notification in
            if let notification = notification {
                action(notification)
            }
        }
    }
}

// MARK: - Environment Key

@available(iOS 13.0, *)
private struct PushServiceKey: EnvironmentKey {
    static let defaultValue = LWPushService.shared
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    /// Access push service from environment
    public var pushService: LWPushService {
        get { self[PushServiceKey.self] }
        set { self[PushServiceKey.self] = newValue }
    }
}

// MARK: - Sample SwiftUI View

@available(iOS 13.0, *)
struct PushNotificationBadgeView: View {
    @ObservedObject var state: LWPushState

    var body: some View {
        if state.badgeNumber > 0 {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)

                Text("\(state.badgeNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Notification Banner View

@available(iOS 13.0, *)
public struct LWPushNotificationBanner: View {
    let notification: LWPushNotificationInfo
    let onTap: () -> Void
    let onDismiss: () -> Void

    @State private var isVisible = false

    public init(notification: LWPushNotificationInfo,
                onTap: @escaping () -> Void = {},
                onDismiss: @escaping () -> Void = {}) {
        self.notification = notification
        self.onTap = onTap
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let title = notification.title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            if let body = notification.body {
                Text(body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal)
        .offset(y: isVisible ? 0 : -100)
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Push Settings View

@available(iOS 13.0, *)
public struct LWPushSettingsView: View {
    @ObservedObject var state: LWPushState
    @State private var accountInput: String = ""

    public init(state: LWPushState) {
        self.state = state
    }

    public var body: some View {
        Form {
            Section(header: Text("Notification Status")) {
                HStack {
                    Text("Notifications Enabled")
                    Spacer()
                    Image(systemName: state.isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(state.isEnabled ? .green : .red)
                }

                if let token = state.deviceToken {
                    VStack(alignment: .leading) {
                        Text("Device Token")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(token)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(1)
                    }
                }

                HStack {
                    Text("Badge Number")
                    Spacer()
                    Text("\(state.badgeNumber)")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Account Binding")) {
                ForEach(Array(state.boundAccounts), id: \.self) { account in
                    HStack {
                        Text(account)
                        Spacer()
                        Button(action: {
                            LWPushService.shared.unbind(account: account)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                HStack {
                    TextField("Account ID", text: $accountInput)
                    Button(action: {
                        guard !accountInput.isEmpty else { return }
                        LWPushService.shared.bind(account: accountInput)
                        accountInput = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }

            Section {
                Button(action: {
                    LWPushService.shared.setBadge(0)
                }) {
                    Text("Clear Badge")
                        .foregroundColor(.red)
                }

                Button(action: {
                    state.checkAuthorizationStatus()
                }) {
                    Text("Refresh Status")
                }
            }
        }
        .navigationTitle("Push Notifications")
    }
}
