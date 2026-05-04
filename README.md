# LWPusher


## graphify Knowledge Graph

- Interactive graph: https://luowei.github.io/LWPusher/
- Report: https://luowei.github.io/LWPusher/GRAPH_REPORT.md
- Graph data: https://luowei.github.io/LWPusher/graph.json

[![CI Status](https://img.shields.io/travis/luowei/LWPusher.svg?style=flat)](https://travis-ci.org/luowei/LWPusher)
[![Version](https://img.shields.io/cocoapods/v/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)
[![License](https://img.shields.io/cocoapods/l/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)
[![Platform](https://img.shields.io/cocoapods/p/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start Guide](#quick-start-guide)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Push Notification Format](#push-notification-format)
- [XGPush Integration](#xgpush-integration)
- [Certificate Configuration](#certificate-configuration)
- [Example Project](#example-project)
- [Debug Mode](#debug-mode)
- [Important Notes](#important-notes)
- [Troubleshooting](#troubleshooting)
- [Links](#links)
- [Support](#support)
- [Version History](#version-history)
- [Author](#author)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Introduction

LWPusher is an iOS push notification wrapper library based on **Tencent XGPush** (formerly known as Tencent Mobile Push). It provides a clean, intuitive, and easy-to-use API interface that helps developers quickly integrate push notification functionality into their iOS applications with minimal configuration.

## Features

- **Simple Integration**: Clean singleton pattern design for effortless implementation
- **Complete SDK Wrapper**: Full encapsulation of Tencent XGPush SDK functionality
- **Account Management**: Support for account binding and unbinding for targeted push notifications
- **Custom URL Handling**: Built-in support for deep linking and custom URL schemes
- **Badge Management**: Easy badge number control and synchronization
- **Wide Compatibility**: Support for iOS 8.0 and above
- **Comprehensive Delegates**: Complete implementation of push notification delegate methods
- **Foreground & Background**: Handle notifications in all app states seamlessly
- **Debug Support**: Detailed logging in debug mode for easy troubleshooting
- **iOS 10+ Support**: Full UNUserNotificationCenter delegate implementation
- **Advanced Features**: Access to XGPush delegate callbacks for custom functionality
- **Tag Support**: Organize users with tags for grouped push notifications
- **Geo-targeting**: Location-based notification support
- **Analytics**: Built-in notification statistics and reporting

## Requirements

- iOS 8.0 or later
- Xcode development environment
- CocoaPods package manager
- Valid Tencent XGPush AppID and AppKey

## Installation

LWPusher is available through [CocoaPods](https://cocoapods.org), the dependency manager for Swift and Objective-C projects.

### CocoaPods Installation

1. Add the following line to your `Podfile`:

```ruby
pod 'LWPusher'
```

For Swift version, use:

```ruby
pod 'LWPusher_swift'
```

See [Swift Version Documentation](README_SWIFT_VERSION.md) for more details.

2. Install the pod by running:

```bash
pod install
```

3. Import the library in your source files:

```objective-c
#import "LWPushManager.h"
```

### Manual Installation

If you prefer not to use CocoaPods:

1. Download or clone this repository
2. Add all files from the `LWPusher` directory to your Xcode project
3. Ensure the required frameworks are linked (see [Required Frameworks](#required-frameworks))
4. Import the header file where needed

## Quick Start Guide

Get up and running with LWPusher in just a few minutes.

### Step 1: Register for Tencent XGPush

1. Visit the [Tencent XGPush Console](https://xg.qq.com/)
2. Create an application and obtain your `AppID` and `AppKey`
3. Upload your APNs certificates (see [Certificate Configuration](#certificate-configuration) for details)

### Step 2: Import Header

In your `AppDelegate.m`, import the header file:

```objective-c
#import "LWPushManager.h"
```

### Step 3: Initialize Push Service

In `application:didFinishLaunchingWithOptions:`, configure and start the push service:

```objective-c
- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure with your AppID and AppKey
    [[LWPushManager shareManager] configAppID:YOUR_APP_ID
                                       appKey:@"YOUR_APP_KEY"];

    // Handle push notification on app launch
    [[LWPushManager shareManager] handPushInApplicationDidFinishLaunchingWithOptions:launchOptions];

    return YES;
}
```

> **Note**: Replace `YOUR_APP_ID` with your actual numeric AppID and `YOUR_APP_KEY` with your string AppKey from the XGPush console.

### Step 4: Register for Remote Notifications

Implement the device token registration callbacks:

```objective-c
- (void)application:(UIApplication *)application
        didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Device token is automatically handled by XGPush SDK
    NSLog(@"Successfully registered for remote notifications");
}

- (void)application:(UIApplication *)application
        didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}
```

### Step 5: Handle Push Notifications

Implement notification handling for both foreground and background states:

```objective-c
// For iOS 7-9 (Legacy)
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Clear badge
    application.applicationIconBadgeNumber = 0;

    // Handle push notification
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];
}

// For iOS 10+ (Recommended - supports background push)
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    // Clear badge
    application.applicationIconBadgeNumber = 0;

    // Handle push notification
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];

    // Call completion handler
    completionHandler(UIBackgroundFetchResultNewData);
}
```

**That's it!** Your app is now ready to receive push notifications.

## Usage

### Account Binding

Bind user accounts to enable targeted push notifications to specific users. This is useful for sending personalized notifications based on user login.

```objective-c
// Bind account (for single-user targeted push)
[[LWPushManager shareManager] bindAccount:@"user_account_id"];

// Unbind account (on logout)
[[LWPushManager shareManager] unbindAccount:@"user_account_id"];
```

**Best Practice**: Bind accounts after user login and unbind on logout.

### Start and Stop Push Service

Control the push service lifecycle:

```objective-c
// Start push service
[[LWPushManager shareManager] startXGPush];

// Stop push service (useful for app settings)
[[LWPushManager shareManager] stopXGPush];
```

### Badge Management

Manage the app icon badge number:

```objective-c
// Set badge number through XGPush
[[XGPush defaultManager] setXgApplicationBadgeNumber:0];

// Get current badge number
NSInteger badgeNumber = [[XGPush defaultManager] xgApplicationBadgeNumber];

// Clear badge
[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
```

### Tag Management

Organize users into groups using tags for targeted notifications:

```objective-c
// Bind a tag to the current device
[[XGPushTokenManager defaultTokenManager] bindWithIdentifier:@"VIP_users"
                                                         type:XGPushTokenBindTypeTag];

// Unbind a tag
[[XGPushTokenManager defaultTokenManager] unbindWithIdentifier:@"VIP_users"
                                                           type:XGPushTokenBindTypeTag];
```

### Device Token

Access the device token string:

```objective-c
// Get device token
NSString *deviceToken = [[XGPushTokenManager defaultTokenManager] deviceTokenString];
NSLog(@"Device Token: %@", deviceToken);
```

## API Reference

Complete API documentation for LWPushManager and related classes.

### LWPushManager

The main interface for managing push notifications.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `appID` | `uint32_t` | Tencent XGPush assigned application ID |
| `appKey` | `NSString*` | Tencent XGPush assigned application key |

#### Methods

##### Singleton Method

```objective-c
+ (instancetype)shareManager;
```

Returns the shared LWPushManager singleton instance.

**Returns**: Singleton instance of LWPushManager

##### Configuration Method

```objective-c
- (instancetype)configAppID:(uint32_t)appID appKey:(NSString *)appKey;
```

Configure the application's AppID and AppKey. Must be called before using any push features.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `appID` | `uint32_t` | Tencent XGPush assigned application ID |
| `appKey` | `NSString*` | Tencent XGPush assigned application key |

**Returns**: LWPushManager instance (supports method chaining)

**Example:**
```objective-c
[[LWPushManager shareManager] configAppID:1234567890 appKey:@"ABCDEFG123"];
```

##### Push Service Control

```objective-c
- (void)startXGPush;
```

Start the XGPush service and register for remote notifications.

**Example:**
```objective-c
[[LWPushManager shareManager] startXGPush];
```

---

```objective-c
- (void)stopXGPush;
```

Stop the XGPush service. Call this when user disables notifications in app settings.

**Example:**
```objective-c
[[LWPushManager shareManager] stopXGPush];
```

##### Account Management

```objective-c
- (void)bindAccount:(NSString *)account;
```

Bind a user account to the current device for targeted push notifications.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `account` | `NSString*` | Unique user account identifier |

**Example:**
```objective-c
// Bind account after user login
[[LWPushManager shareManager] bindAccount:@"user12345"];
```

---

```objective-c
- (void)unbindAccount:(NSString *)account;
```

Unbind a user account from the current device.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `account` | `NSString*` | User account identifier to unbind |

**Example:**
```objective-c
// Unbind account on user logout
[[LWPushManager shareManager] unbindAccount:@"user12345"];
```

##### Push Notification Handling

```objective-c
- (void)handPushInApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
```

Handle push notifications when the app launches from a notification tap.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `launchOptions` | `NSDictionary*` | Application launch options dictionary |

**Example:**
```objective-c
- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[LWPushManager shareManager] handPushInApplicationDidFinishLaunchingWithOptions:launchOptions];
    return YES;
}
```

---

```objective-c
- (void)handRemotePushNotificationWithUserInfo:(NSDictionary *)userInfo;
```

Handle received push notifications. If the push data contains a `url` field, it will automatically open the corresponding URL using `UIApplication openURL:`.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `userInfo` | `NSDictionary*` | Push notification payload dictionary |

**Example:**
```objective-c
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
```

## Push Notification Format

Understanding the notification payload structure for custom handling.

### Standard APNs Format

```json
{
  "aps": {
    "alert": {
      "title": "Notification Title",
      "body": "Notification message content"
    },
    "badge": 1,
    "sound": "default"
  }
}
```

### Custom URL Handling

LWPusher supports automatic URL opening by including a `url` field in the notification payload:

```json
{
  "aps": {
    "alert": "You have a new message",
    "badge": 1,
    "sound": "default"
  },
  "url": "https://example.com/page",
  "title": "Custom Title",
  "content": "Additional content"
}
```

**Behavior**: When a user taps the notification, the app will automatically open the specified URL using `UIApplication openURL:`. This works for:
- Web URLs (`https://`, `http://`)
- Custom URL schemes (`myapp://`, `fb://`, etc.)
- Universal Links

### Deep Linking Example

```json
{
  "aps": {
    "alert": "Check out this new feature!",
    "badge": 1
  },
  "url": "myapp://feature/detail/123"
}
```

Make sure your app supports the URL scheme in `Info.plist`.

## XGPush Integration

LWPusher is built on top of the powerful Tencent XGPush SDK, providing full access to all SDK features.

### XGPush SDK Features

LWPusher integrates the complete Tencent XGPush SDK, offering:

- **Device Token Management**: Automatic device token registration and synchronization
- **Tag Management**: Bind/unbind tags for organized group push notifications
- **Account Management**: Bind/unbind accounts for personalized user-specific notifications
- **Badge Reporting**: Sync badge numbers with XGPush server for consistency
- **Location Reporting**: Report device location for geo-targeted push campaigns
- **Notification Statistics**: Automatic notification delivery and open rate tracking
- **Rich Notifications**: Support for custom notification actions, categories, and media
- **Multi-platform**: Unified push across iOS and other platforms
- **High Delivery**: Leverages Tencent's infrastructure for reliable message delivery

### XGPush Delegate Methods

LWPushManager implements comprehensive XGPush delegate callbacks for complete control:

#### Service Lifecycle

```objective-c
// Called when push service starts
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error;

// Called when push service stops
- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error;
```

#### Device Token Registration

```objective-c
// Called after device token registration
- (void)xgPushDidRegisteredDeviceToken:(NSString *)deviceToken error:(NSError *)error;
```

#### Notification Handling (iOS 10+)

```objective-c
// Called when notification is received while app is in foreground
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center
              willPresentNotification:(UNNotification *)notification
                withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

// Called when user taps on notification
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center
       didReceiveNotificationResponse:(UNNotificationResponse *)response
                withCompletionHandler:(void (^)(void))completionHandler;
```

#### Badge Management

```objective-c
// Called after badge number is set
- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error;
```

#### Notification Reporting

```objective-c
// Called after notification is reported to XGPush server
- (void)xgPushDidReportNotification:(BOOL)isSuccess error:(NSError *)error;
```

#### Account/Tag Binding

```objective-c
// Called after binding account or tag
- (void)xgPushDidBindWithIdentifier:(NSString *)identifier
                               type:(XGPushTokenBindType)type
                              error:(NSError *)error;

// Called after unbinding account or tag
- (void)xgPushDidUnbindWithIdentifier:(NSString *)identifier
                                 type:(XGPushTokenBindType)type
                                error:(NSError *)error;
```

### Advanced XGPush Features

Access powerful XGPush features directly through the SDK for advanced use cases:

#### Query Device Token

```objective-c
// Get the device token string
NSString *token = [[XGPushTokenManager defaultTokenManager] deviceTokenString];
NSLog(@"Device Token: %@", token);
```

#### Tag Management for Grouped Push

```objective-c
// Bind tags for segmented notifications (e.g., "VIP", "NewUser", "iOS")
[[XGPushTokenManager defaultTokenManager] bindWithIdentifier:@"VIP_users"
                                                         type:XGPushTokenBindTypeTag];

// Unbind tags
[[XGPushTokenManager defaultTokenManager] unbindWithIdentifier:@"VIP_users"
                                                           type:XGPushTokenBindTypeTag];
```

#### Geo-Location Reporting

```objective-c
// Report location for geo-targeted push campaigns
[[XGPush defaultManager] reportLocationWithLatitude:39.9042
                                          longitude:116.4074];
```

#### Badge Synchronization

```objective-c
// Sync badge number with XGPush server
[[XGPush defaultManager] setBadge:7];
```

#### Check Notification Permissions

```objective-c
// Check if user has granted notification permissions
[[XGPush defaultManager] deviceNotificationIsAllowed:^(BOOL isAllowed) {
    if (isAllowed) {
        NSLog(@"Notifications are enabled");
    } else {
        NSLog(@"Notifications are disabled - prompt user to enable");
    }
}];
```

#### SDK Version Information

```objective-c
// Get current XGPush SDK version
NSString *version = [[XGPush defaultManager] sdkVersion];
NSLog(@"XGPush SDK Version: %@", version);
```

## Certificate Configuration

Proper certificate configuration is crucial for push notifications to work correctly.

### Prerequisites

- Apple Developer Account
- App registered in Apple Developer Center
- Valid Bundle ID matching your app

### Step-by-Step Certificate Setup

#### 1. Create Push Certificates in Apple Developer Center

1. Log in to [Apple Developer Center](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** > Choose your App ID
4. Enable **Push Notifications** capability
5. Create certificates for both Development and Production environments

#### 2. Download and Export Certificates

1. Download the `.cer` files from Apple Developer Center
2. Double-click to install in Keychain Access
3. In Keychain Access, right-click on the certificate
4. Select **Export** and save as `.p12` format
5. Set a password (you'll need this for conversion)

#### 3. Convert to PEM Format

Use OpenSSL to convert `.p12` certificates to `.pem` format:

```bash
# Production environment certificate
openssl pkcs12 -in aps_production.p12 -out aps_production.pem -nodes

# Development environment certificate
openssl pkcs12 -in aps_development.p12 -out aps_development.pem -nodes
```

> **Note**: You'll be prompted to enter the password you set during export.

#### 4. Upload to Tencent XGPush Console

1. Log in to [Tencent XGPush Console](https://xg.qq.com/)
2. Navigate to your application
3. Go to **Configuration** > **iOS Push Certificate**
4. Upload the appropriate `.pem` file for each environment
5. Save and verify the certificate is valid

### Certificate Types

| Environment | Use Case | Certificate Type |
|-------------|----------|-----------------|
| **Development** | Testing on devices via Xcode | APNs Development Certificate |
| **Production** | App Store, TestFlight, Ad Hoc | APNs Production Certificate |

### Troubleshooting Certificates

- **Invalid Certificate Error**: Ensure Bundle ID matches between app and certificate
- **Certificate Expired**: Renew certificates in Apple Developer Center
- **No Notifications Received**: Verify correct environment (development vs production)

## Required Frameworks

LWPusher depends on several iOS system frameworks. These are automatically linked when using CocoaPods.

### Framework Dependencies

| Framework | Purpose | Link Type |
|-----------|---------|-----------|
| `Foundation.framework` | Core iOS foundation classes | Required |
| `UIKit.framework` | UI and application lifecycle | Required |
| `CoreTelephony.framework` | Network and carrier information | Required |
| `SystemConfiguration.framework` | System configuration and reachability | Required |
| `UserNotifications.framework` | iOS 10+ notification handling | Weak (Optional) |
| `libsqlite3.tbd` | Local data storage | Required |
| `libz.tbd` | Data compression | Required |

### Manual Linking (if not using CocoaPods)

If you're manually integrating LWPusher:

1. Select your project in Xcode
2. Choose your target
3. Go to **Build Phases** > **Link Binary With Libraries**
4. Add the frameworks listed above
5. Set `UserNotifications.framework` as **Optional** for iOS 8/9 compatibility

## Example Project

A complete example project is included to demonstrate LWPusher integration and usage.

### Running the Example Project

Follow these steps to run the example:

```bash
# 1. Clone the repository
git clone https://gitlab.com/ioslibraries1/liblwpusher.git

# 2. Navigate to Example directory
cd liblwpusher/Example

# 3. Install dependencies
pod install

# 4. Open workspace
open LWPusher.xcworkspace
```

### Configuration

Before running the example:

1. **Update Credentials**: Open `AppDelegate.m` and replace `YOUR_APP_ID` and `YOUR_APP_KEY` with your actual XGPush credentials
2. **Update Bundle ID**: Change the Bundle Identifier to match your provisioning profile
3. **Select Team**: In project settings, select your development team
4. **Use Physical Device**: Push notifications don't work in the simulator

### Example Features Demonstrated

The example project shows:

- ✅ Basic push notification setup
- ✅ Account binding/unbinding
- ✅ Badge management
- ✅ Custom URL handling
- ✅ Tag management
- ✅ Foreground and background notification handling
- ✅ XGPush delegate callbacks

## Debug Mode

LWPusher includes comprehensive debug logging to help troubleshoot push notification issues during development.

### Logging Configuration

The logging macro is automatically configured based on build configuration:

```objective-c
#ifdef DEBUG
#define PushLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define PushLog(...)
#endif
```

### Debug vs Release Behavior

| Build Configuration | Logging Behavior |
|-------------------|------------------|
| **Debug** | Detailed logs with function names, line numbers, and parameters |
| **Release** | All logs disabled for optimal performance |

### Example Debug Output

When running in Debug mode, you'll see detailed logs like:

```
-[LWPushManager xgPushDidFinishStart:error:] [Line 89]
XGPush started successfully

-[LWPushManager xgPushDidRegisteredDeviceToken:error:] [Line 105]
Device Token: abcd1234...

-[LWPushManager handRemotePushNotificationWithUserInfo:] [Line 145]
Received notification: {
    aps = {
        alert = "Test notification";
    };
    url = "https://example.com";
}
```

### Enabling Debug Logs

Debug logs are enabled by default in Debug builds. No additional configuration needed.

### Disabling Debug Logs

To disable logs in Debug builds, comment out the macro definition in `LWPushManager.m`.

## Important Notes

Key considerations when implementing push notifications with LWPusher:

### Testing Requirements

- **Physical Device Required**: iOS Simulator does not support APNs. You must test on a real device.
- **Network Connection**: Both device and server must have active internet connectivity.
- **Development Certificate**: Use development certificates when testing via Xcode.

### Configuration Requirements

- **Certificate Setup**: Push certificates must be properly configured in the Tencent XGPush console before sending notifications.
- **Bundle ID Match**: The app's Bundle ID must exactly match the Bundle ID in the push certificate.
- **AppID and AppKey**: Ensure correct AppID and AppKey from XGPush console are used in your app.

### Permission Management

- **User Authorization**: Users must grant push notification permissions on first launch.
- **Permission Prompt**: Request permissions at an appropriate time in your app flow.
- **Settings Redirect**: Provide option to redirect users to Settings if permissions are denied.

### Service Lifecycle

- **Service Start**: Ensure `startXGPush` is called before using any push features.
- **Account Binding**: Only bind accounts after the push service has successfully started.
- **Timing**: Initialize push service in `application:didFinishLaunchingWithOptions:`.

### Best Practices

- **Error Handling**: Always implement error handling in delegate callbacks.
- **Badge Management**: Clear badges when appropriate to avoid confusion.
- **URL Validation**: Validate URLs before opening to prevent security issues.
- **Testing**: Test both foreground and background notification scenarios.

## Troubleshooting

Common issues and their solutions.

### 1. Not Receiving Push Notifications

**Symptoms**: Notifications don't appear on the device.

**Solutions**:
- ✅ Verify the device is connected to the internet
- ✅ Confirm push notification permissions are granted in Settings
- ✅ Check that certificates are properly configured in XGPush console
- ✅ Verify AppID and AppKey are correct
- ✅ Ensure you're using the correct environment (development vs production)
- ✅ Check Xcode console for error messages
- ✅ Verify Bundle ID matches certificate Bundle ID exactly

**Testing**:
```objective-c
// Check if notifications are allowed
[[XGPush defaultManager] deviceNotificationIsAllowed:^(BOOL isAllowed) {
    NSLog(@"Notifications allowed: %@", isAllowed ? @"YES" : @"NO");
}];
```

### 2. Simulator Error (Code 3010)

**Symptoms**: Error code 3010 or registration failure in simulator.

**Cause**: iOS Simulator does not support APNs.

**Solution**: Always test push notifications on a physical device connected via USB or wireless debugging.

### 3. Account Binding Failure

**Symptoms**: Account binding doesn't work or fails silently.

**Solutions**:
- ✅ Ensure push service has started successfully (check delegate callback)
- ✅ Verify device token was registered successfully
- ✅ Confirm account string is not nil or empty
- ✅ Wait for `xgPushDidFinishStart:error:` callback before binding

**Example**:
```objective-c
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    if (isSuccess) {
        // Safe to bind account now
        [[LWPushManager shareManager] bindAccount:@"user123"];
    } else {
        NSLog(@"Push start failed: %@", error);
    }
}
```

### 4. Custom URL Not Opening

**Symptoms**: Tapping notification doesn't open the custom URL.

**Solutions**:
- ✅ Verify `url` field exists in notification payload
- ✅ Ensure URL is properly formatted (include scheme: `https://` or `myapp://`)
- ✅ For custom schemes, verify URL scheme is registered in `Info.plist`
- ✅ Check `handRemotePushNotificationWithUserInfo:` is being called

### 5. Certificate Invalid Error

**Symptoms**: Push console shows "Invalid Certificate" or certificate upload fails.

**Solutions**:
- ✅ Ensure `.pem` file was generated correctly from `.p12`
- ✅ Verify password was entered correctly during OpenSSL conversion
- ✅ Check certificate hasn't expired (renew if needed)
- ✅ Confirm certificate type matches environment (dev vs prod)

### 6. Badge Not Updating

**Symptoms**: Badge number doesn't change or sync.

**Solutions**:
- ✅ Call badge management methods on main thread
- ✅ Use both local and server-side badge updates
- ✅ Clear badge when app becomes active

```objective-c
// Update badge properly
dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[XGPush defaultManager] setBadge:0];
});
```

### Getting Help

If issues persist:
1. Enable debug logging and check console output
2. Review XGPush documentation for additional details
3. Submit an issue to the GitLab repository with logs
4. Contact support: luowei@wodedata.com

## Links

### Official Resources

- **CocoaPods**: [https://cocoapods.org/pods/LWPusher](https://cocoapods.org/pods/LWPusher)
- **GitLab Repository**: [https://gitlab.com/ioslibraries1/liblwpusher](https://gitlab.com/ioslibraries1/liblwpusher.git)
- **Tencent XGPush Console**: [https://xg.qq.com/](https://xg.qq.com/)
- **Apple Developer Center**: [https://developer.apple.com/](https://developer.apple.com/)

### Documentation

- **XGPush iOS SDK Documentation**: Available in XGPush console
- **Apple Push Notifications**: [APNs Documentation](https://developer.apple.com/documentation/usernotifications)
- **CocoaPods Guides**: [https://guides.cocoapods.org/](https://guides.cocoapods.org/)

## Support

### Reporting Issues

If you encounter bugs or have feature requests:

1. **Check Existing Issues**: Search the [GitLab Issues](https://gitlab.com/ioslibraries1/liblwpusher/issues) to see if it's already reported
2. **Create New Issue**: Submit a detailed issue with:
   - iOS version and device model
   - Xcode version
   - LWPusher version
   - Steps to reproduce
   - Console logs (with debug enabled)
   - Expected vs actual behavior

### Contact

- **Email**: luowei@wodedata.com
- **GitLab**: Submit an issue or merge request

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Submit a merge request with description of changes

## Version History

### v1.0.0 - Initial Release

**Release Date**: 2019

**Features**:
- ✨ Initial stable release
- ✨ Basic push notification support with APNs
- ✨ Tencent XGPush SDK integration
- ✨ Account binding and unbinding functionality
- ✨ Custom URL handling and deep linking
- ✨ Badge management
- ✨ iOS 8.0+ compatibility
- ✨ Debug logging support
- ✨ Complete delegate method implementation
- ✨ Foreground and background notification handling

**SDK Version**: Built on Tencent XGPush SDK

---

## Author

**luowei** - iOS Developer

- **Email**: luowei@wodedata.com
- **GitLab**: [@luowei](https://gitlab.com/luowei)

## License

LWPusher is released under the **MIT License**. See the [LICENSE](LICENSE) file for complete details.

### MIT License Summary

```text
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

**What this means**: You are free to use, modify, and distribute this library in your projects, including commercial applications, as long as you include the copyright notice.

---

## Acknowledgments

Special thanks to:

- **Tencent XGPush Team** - For providing a robust and reliable push notification infrastructure
- **The iOS Developer Community** - For continuous feedback and contributions
- **CocoaPods** - For simplifying dependency management
- **All Contributors** - For helping improve this library

---

## Star History

If you find LWPusher helpful, please consider giving it a star on GitLab!

---

**Made with ❤️ by the iOS community**
