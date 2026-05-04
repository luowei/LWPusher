# Graph Report - /Users/luowei/projects/libs/LWPusher  (2026-05-04)

## Corpus Check
- Corpus is ~11,756 words - fits in a single context window. You may not need a graph.

## Summary
- 167 nodes · 194 edges · 10 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]

## God Nodes (most connected - your core abstractions)
1. `LWPushManager` - 26 edges
2. `LWPushManager` - 25 edges
3. `pushLog()` - 12 edges
4. `LWAppDelegate` - 11 edges
5. `LWPushService` - 11 edges
6. `LWAppDelegate` - 7 edges
7. `LWPushState` - 7 edges
8. `View` - 7 edges
9. `XGNotificationActionOptions` - 6 edges
10. `LWViewController` - 5 edges

## Surprising Connections (you probably didn't know these)
- `LWPushManager` --inherits--> `NSObject`  [EXTRACTED]
  LWPusher_swift/Swift/LWPushManager.swift →   _Bridges community 1 → community 7_
- `LWPushManager` --inherits--> `UNUserNotificationCenterDelegate`  [EXTRACTED]
  LWPusher_swift/Swift/LWPushManager.swift →   _Bridges community 1 → community 0_
- `PushViewModel` --inherits--> `ObservableObject`  [EXTRACTED]
  LWPusher_swift/Swift/LWPushSwiftExample.swift →   _Bridges community 4 → community 3_

## Communities (17 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (25): LWPushManager, -bindAccount, -configAppIDappKey, -handPushInApplicationDidFinishLaunchingWithOptions, -handRemotePushNotificationWithUserInfo, -openURL, -shareManager, -startXGPush (+17 more)

### Community 2 - "Community 2"
Cohesion: 0.1
Nodes (19): OptionSet, LWPushResult, failure, success, XGNotificationActionOptions, authenticationRequired, destructive, foreground (+11 more)

### Community 3 - "Community 3"
Cohesion: 0.12
Nodes (11): App, ContentView, ExampleAppDelegate, ExampleSwiftUIApp, ExampleViewController, PushViewModel, StatusRow, UIApplicationDelegate (+3 more)

### Community 4 - "Community 4"
Cohesion: 0.15
Nodes (3): ObservableObject, LWPushService, LWPushState

### Community 5 - "Community 5"
Cohesion: 0.17
Nodes (11): LWAppDelegate, -applicationdidFailToRegisterForRemoteNotificationsWithError, -applicationdidReceiveLocalNotification, -applicationdidReceiveRemoteNotification, -applicationdidReceiveRemoteNotificationfetchCompletionHandler, -applicationdidRegisterForRemoteNotificationsWithDeviceToken, -applicationdidRegisterUserNotificationSettings, -applicationhandleActionWithIdentifierforLocalNotificationcompletionHandler (+3 more)

### Community 6 - "Community 6"
Cohesion: 0.24
Nodes (7): EnvironmentKey, EnvironmentValues, LWPushNotificationBanner, LWPushSettingsView, PushNotificationBadgeView, PushServiceKey, View

### Community 7 - "Community 7"
Cohesion: 0.22
Nodes (4): NSObject, AdvancedPushExample, LWPushConfiguration, LWPushNotificationInfo

### Community 8 - "Community 8"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 9 - "Community 9"
Cohesion: 0.33
Nodes (5): LWViewController, -bindAction, -didReceiveMemoryWarning, -unbindAction, -viewDidLoad

## Knowledge Gaps
- **56 isolated node(s):** `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground`, `-applicationWillEnterForeground`, `-applicationDidBecomeActive` (+51 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWPushManager` connect `Community 1` to `Community 0`, `Community 7`?**
  _High betweenness centrality (0.371) - this node is a cross-community bridge._
- **Why does `LWPushNotificationInfo` connect `Community 7` to `Community 2`?**
  _High betweenness centrality (0.299) - this node is a cross-community bridge._
- **Why does `LWPushService` connect `Community 4` to `Community 6`, `Community 7`?**
  _High betweenness centrality (0.213) - this node is a cross-community bridge._
- **What connects `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground` to the rest of the system?**
  _56 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._