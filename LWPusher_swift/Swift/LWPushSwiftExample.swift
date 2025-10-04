//
// LWPushSwiftExample.swift
// Example usage of LWPusher in Swift
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//

import UIKit
import SwiftUI
import UserNotifications

// MARK: - AppDelegate Integration Example

class ExampleAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure push notifications
        LWPushManager.shared
            .configure(appID: 2200198799, appKey: "I4511B1BNREA")

        // Handle push in launch options
        LWPushManager.shared.handlePushInApplicationDidFinishLaunching(options: launchOptions)

        // Request notification authorization
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = LWPushManager.shared
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                print("Notification authorization granted: \(granted)")
                if let error = error {
                    print("Error: \(error)")
                }
            }
            application.registerForRemoteNotifications()
        }

        return true
    }

    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LWPushManager.shared.handleRemotePushNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}

// MARK: - UIKit Example

class ExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPushNotifications()
    }

    private func setupPushNotifications() {
        // Bind account
        LWPushManager.shared.bindAccount("user_12345")

        // Set badge
        LWPushManager.shared.setBadgeNumber(0)

        // Get current badge
        let currentBadge = LWPushManager.shared.getBadgeNumber()
        print("Current badge: \(currentBadge)")
    }

    deinit {
        // Unbind account when view is deallocated
        LWPushManager.shared.unbindAccount("user_12345")
    }
}

// MARK: - SwiftUI Example

@available(iOS 13.0, *)
struct ExampleSwiftUIApp: App {

    @StateObject private var pushService = LWPushService.shared

    init() {
        // Configure push on app launch
        LWPushService.shared.configure(appID: 2200198799, appKey: "I4511B1BNREA")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pushService)
                .onAppear {
                    pushService.start()
                }
        }
    }
}

@available(iOS 13.0, *)
struct ContentView: View {
    @EnvironmentObject var pushService: LWPushService
    @State private var showingNotification = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Push status
                GroupBox(label: Label("Push Status", systemImage: "bell.fill")) {
                    VStack(alignment: .leading, spacing: 10) {
                        StatusRow(title: "Enabled",
                                 value: pushService.state.isEnabled ? "Yes" : "No",
                                 color: pushService.state.isEnabled ? .green : .red)

                        StatusRow(title: "Badge",
                                 value: "\(pushService.state.badgeNumber)",
                                 color: .blue)

                        if !pushService.state.boundAccounts.isEmpty {
                            StatusRow(title: "Bound Accounts",
                                     value: "\(pushService.state.boundAccounts.count)",
                                     color: .purple)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        pushService.bind(account: "user_\(Int.random(in: 1000...9999))")
                    }) {
                        Label("Bind Account", systemImage: "person.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        pushService.setBadge(0)
                    }) {
                        Label("Clear Badge", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    NavigationLink(destination: LWPushSettingsView(state: pushService.state)) {
                        Label("Settings", systemImage: "gear")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Push Demo")
            .onPushNotificationTap { notification in
                print("Notification tapped: \(notification.userInfo)")
                showingNotification = true
            }
            .alert("Notification Received", isPresented: $showingNotification) {
                Button("OK", role: .cancel) {}
            } message: {
                if let latest = pushService.state.latestNotification {
                    Text(latest.body ?? "No message")
                }
            }
        }
    }
}

@available(iOS 13.0, *)
struct StatusRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .bold()
        }
    }
}

// MARK: - Advanced Usage Example

@available(iOS 13.0, *)
struct AdvancedPushExample {

    /// Setup push with custom configuration
    static func setupWithConfiguration() {
        let config = LWPushConfiguration(
            appID: 2200198799,
            appKey: "I4511B1BNREA",
            enableDebug: true
        )

        LWPushManager.shared.configure(
            appID: config.appID,
            appKey: config.appKey
        )
    }

    /// Handle notification with URL
    static func handleNotificationWithURL(userInfo: [AnyHashable: Any]) {
        let notificationInfo = LWPushNotificationInfo(userInfo: userInfo)

        if let url = notificationInfo.url {
            print("Opening URL: \(url)")
            UIApplication.shared.open(url)
        }

        if let badge = notificationInfo.badge {
            LWPushManager.shared.setBadgeNumber(badge)
        }
    }

    /// Bind multiple accounts
    static func bindMultipleAccounts(_ accounts: [String]) {
        accounts.forEach { account in
            LWPushManager.shared.bindAccount(account)
        }
    }

    /// Handle push in background
    static func handleBackgroundPush(userInfo: [AnyHashable: Any],
                                    completion: @escaping (UIBackgroundFetchResult) -> Void) {
        LWPushManager.shared.handleRemotePushNotification(userInfo: userInfo)

        // Perform background work
        DispatchQueue.global().async {
            // Simulate work
            Thread.sleep(forTimeInterval: 2)

            DispatchQueue.main.async {
                completion(.newData)
            }
        }
    }
}

// MARK: - Combine Integration Example

@available(iOS 13.0, *)
class PushViewModel: ObservableObject {
    @Published var notifications: [LWPushNotificationInfo] = []
    @Published var isConnected = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        observePushState()
    }

    private func observePushState() {
        LWPushService.shared.state.$latestNotification
            .compactMap { $0 }
            .sink { [weak self] notification in
                self?.notifications.append(notification)
            }
            .store(in: &cancellables)

        LWPushService.shared.state.$isEnabled
            .sink { [weak self] isEnabled in
                self?.isConnected = isEnabled
            }
            .store(in: &cancellables)
    }

    func clearAllNotifications() {
        notifications.removeAll()
        LWPushService.shared.setBadge(0)
    }
}
