# LWPusher Swift版本使用说明

## 概述

LWPusher提供了Swift版本的实现，专门为使用Swift开发的项目优化，提供更现代化的推送服务集成。

## 安装

### CocoaPods

在你的`Podfile`中添加：

```ruby
pod 'LWPusher_swift'
```

然后运行：

```bash
pod install
```

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Swift版本包含的功能

Swift版本包含以下组件：

- `LWPushManager.swift` - 推送管理器
- `XGPushTypes.swift` - 推送类型定义
- `LWPushSwiftUI.swift` - SwiftUI支持
- `LWPushSwiftExample.swift` - 使用示例

## 使用示例

### 基础用法

```swift
import LWPusher_swift

// 初始化推送管理器
LWPushManager.shared.configure()

// 注册推送
LWPushManager.shared.registerForPushNotifications()
```

### SwiftUI集成

```swift
import SwiftUI
import LWPusher_swift

struct ContentView: View {
    var body: some View {
        VStack {
            Text("推送示例")
        }
        .onAppear {
            LWPushManager.shared.configure()
        }
    }
}
```

## 与Objective-C版本的区别

- Swift版本要求iOS 13.0+（Objective-C版本支持iOS 8.0+）
- Swift版本提供了SwiftUI支持
- Swift版本使用现代Swift语法和Combine框架
- 提供更类型安全的API

## 注意事项

- 如果你的项目同时使用Objective-C和Swift，可以同时安装`LWPusher`和`LWPusher_swift`
- Swift版本与Objective-C版本可以共存，互不影响
- 确保在Apple Developer Portal中正确配置了推送证书

## 许可证

LWPusher_swift遵循MIT许可证。详见LICENSE文件。
