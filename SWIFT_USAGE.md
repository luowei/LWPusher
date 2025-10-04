# LWPusher - Swift/SwiftUI Usage Guide

Modern Swift and SwiftUI wrapper for Tencent XGPush SDK.

## Overview

LWPusher provides a clean, type-safe Swift API for integrating Tencent's XGPush (信鸽推送) SDK into iOS applications. The library includes both UIKit and SwiftUI support with modern Swift patterns.

## Features

- ✅ Swift 5.0+ with modern async patterns
- ✅ SwiftUI integration with reactive state management
- ✅ Type-safe enums and option sets
- ✅ Combine framework support
- ✅ Observable state management
- ✅ Environment-based dependency injection
- ✅ Custom SwiftUI view modifiers
- ✅ Comprehensive examples

## Requirements

- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+
- SwiftUI features require iOS 13.0+

## Installation

### CocoaPods

```ruby
pod 'LWPusher', '~> 2.0'
```

## Quick Start

### UIKit Integration

#### 1. Configure in AppDelegate

```swift
import UIKit
import LWPusher
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure push notifications
        LWPushManager.shared.configure(appID: YOUR_APP_ID, appKey: "YOUR_APP_KEY")

        // Handle push in launch options
        LWPushManager.shared.handlePushInApplicationDidFinishLaunching(options: launchOptions)

        // Request notification authorization
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = LWPushManager.shared
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                print("Notification authorization: \(granted)")
            }
        }

        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LWPushManager.shared.handleRemotePushNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}
```

#### 2. Use in View Controllers

```swift
import LWPusher

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind user account
        LWPushManager.shared.bindAccount("user_12345")

        // Clear badge
        LWPushManager.shared.setBadgeNumber(0)
    }

    deinit {
        // Unbind account
        LWPushManager.shared.unbindAccount("user_12345")
    }
}
```

### SwiftUI Integration

#### 1. Setup in App

```swift
import SwiftUI
import LWPusher

@main
struct MyApp: App {
    @StateObject private var pushService = LWPushService.shared

    init() {
        LWPushService.shared.configure(appID: YOUR_APP_ID, appKey: "YOUR_APP_KEY")
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
```

#### 2. Use in Views

```swift
import SwiftUI
import LWPusher

struct ContentView: View {
    @EnvironmentObject var pushService: LWPushService

    var body: some View {
        VStack {
            Text("Badge: \(pushService.state.badgeNumber)")

            Button("Bind Account") {
                pushService.bind(account: "user_12345")
            }

            Button("Clear Badge") {
                pushService.setBadge(0)
            }
        }
        .setupPushNotifications(appID: YOUR_APP_ID, appKey: "YOUR_APP_KEY")
        .bindPushAccount("user_12345")
        .onPushNotificationTap { notification in
            print("Notification tapped: \(notification.userInfo)")
        }
    }
}
```

#### 3. Use Push Settings View

```swift
import SwiftUI
import LWPusher

struct SettingsView: View {
    @EnvironmentObject var pushService: LWPushService

    var body: some View {
        NavigationView {
            LWPushSettingsView(state: pushService.state)
        }
    }
}
```

## API Reference

### LWPushManager

The main singleton class for managing push notifications.

#### Properties

```swift
var appID: UInt32          // XGPush App ID
var appKey: String         // XGPush App Key
static let shared          // Shared instance
```

#### Methods

```swift
// Configuration
func configure(appID: UInt32, appKey: String) -> Self

// Push Control
func startXGPush()
func stopXGPush()

// Account Binding
func bindAccount(_ account: String)
func unbindAccount(_ account: String)

// Badge Management
func setBadgeNumber(_ number: Int)
func getBadgeNumber() -> Int

// Push Handling
func handlePushInApplicationDidFinishLaunching(options: [UIApplication.LaunchOptionsKey: Any]?)
func handleRemotePushNotification(userInfo: [AnyHashable: Any])
```

### LWPushService

SwiftUI-friendly push notification service with Combine support.

#### Properties

```swift
static let shared                    // Shared instance
@Published var state: LWPushState   // Observable state
```

#### Methods

```swift
func configure(appID: UInt32, appKey: String)
func start()
func stop()
func bind(account: String)
func unbind(account: String)
func setBadge(_ number: Int)
func getBadge() -> Int
func handleNotification(userInfo: [AnyHashable: Any])
```

### LWPushState

Observable state object for push notifications.

#### Properties

```swift
@Published var isEnabled: Bool                              // Notification enabled status
@Published var deviceToken: String?                         // Device token
@Published var badgeNumber: Int                            // Current badge number
@Published var latestNotification: LWPushNotificationInfo? // Latest notification
@Published var boundAccounts: Set<String>                  // Bound accounts
```

### View Modifiers

SwiftUI view modifiers for easy integration.

```swift
// Setup push notifications
.setupPushNotifications(appID: UInt32, appKey: String)

// Bind account for view lifecycle
.bindPushAccount(_ account: String)

// Handle notification taps
.onPushNotificationTap { notification in
    // Handle notification
}
```

## Advanced Usage

### Custom Notification Handling

```swift
import LWPusher

let notificationInfo = LWPushNotificationInfo(userInfo: userInfo)

if let url = notificationInfo.url {
    // Open URL from notification
    UIApplication.shared.open(url)
}

if let badge = notificationInfo.badge {
    // Update badge
    LWPushManager.shared.setBadgeNumber(badge)
}

print("Title: \(notificationInfo.title ?? "N/A")")
print("Body: \(notificationInfo.body ?? "N/A")")
```

### Combine Integration

```swift
import Combine
import LWPusher

class PushViewModel: ObservableObject {
    @Published var notifications: [LWPushNotificationInfo] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        LWPushService.shared.state.$latestNotification
            .compactMap { $0 }
            .sink { [weak self] notification in
                self?.notifications.append(notification)
            }
            .store(in: &cancellables)
    }
}
```

### Custom Configuration

```swift
let config = LWPushConfiguration(
    appID: YOUR_APP_ID,
    appKey: "YOUR_APP_KEY",
    enableDebug: true
)

LWPushManager.shared.configure(
    appID: config.appID,
    appKey: config.appKey
)
```

### Multiple Account Binding

```swift
let accounts = ["user_123", "guest_456", "admin_789"]
accounts.forEach { account in
    LWPushManager.shared.bindAccount(account)
}
```

## Type Definitions

### XGPushTokenBindType

```swift
enum XGPushTokenBindType: UInt {
    case none     // Not bound
    case account  // Bound to account
    case tag      // Bound to tag
}
```

### XGUserNotificationTypes

```swift
struct XGUserNotificationTypes: OptionSet {
    static let none
    static let badge
    static let sound
    static let alert
    static let carPlay
    static let criticalAlert
    static let providesAppNotificationSettings
    static let provisional
    static let all  // [.badge, .sound, .alert]
}
```

## SwiftUI Components

### Notification Banner

```swift
LWPushNotificationBanner(
    notification: notification,
    onTap: {
        // Handle tap
    },
    onDismiss: {
        // Handle dismiss
    }
)
```

### Settings View

```swift
LWPushSettingsView(state: pushService.state)
```

## Debug Logging

Debug logging is automatically enabled in DEBUG builds:

```swift
#if DEBUG
func pushLog(_ message: String, function: String = #function, line: Int = #line) {
    print("\(function) [Line \(line)]\n\(message)\n\n")
}
#endif
```

## Best Practices

1. **Configure Early**: Configure push service in `application:didFinishLaunchingWithOptions:`
2. **Request Permissions**: Always request notification permissions before starting push service
3. **Bind on Login**: Bind user account after successful login
4. **Unbind on Logout**: Unbind account when user logs out
5. **Clear Badge**: Clear badge when appropriate (app launch, notification viewed)
6. **Handle Background**: Properly handle push notifications in background state
7. **Test Thoroughly**: Test with both foreground and background scenarios

## Troubleshooting

### Notifications Not Received

1. Check notification permissions: Settings > Your App > Notifications
2. Verify App ID and App Key are correct
3. Ensure device token is registered
4. Check XGPush console for device status
5. Enable debug logging to see detailed logs

### Account Binding Issues

1. Verify account string is not empty
2. Check that push service is started before binding
3. Confirm notification permissions are granted
4. Review delegate callbacks for error information

### SwiftUI State Not Updating

1. Ensure `@StateObject` or `@ObservedObject` is used correctly
2. Verify `LWPushService.shared` is injected via `@EnvironmentObject`
3. Check that state updates are on main thread

## Migration from Objective-C

The Swift version maintains API compatibility with the Objective-C version:

```swift
// Objective-C
[[LWPushManager shareManager] configAppID:appID appKey:appKey];
[[LWPushManager shareManager] startXGPush];

// Swift
LWPushManager.shared.configure(appID: appID, appKey: appKey)
LWPushManager.shared.startXGPush()
```

## License

MIT License. See LICENSE file for details.

## Support

For issues and questions, please refer to:
- XGPush Documentation: http://xg.qq.com/docs/
- GitHub Issues: https://gitlab.com/ioslibraries1/liblwpusher/issues
