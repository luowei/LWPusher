# LWPusher

[![CI Status](https://img.shields.io/travis/luowei/LWPusher.svg?style=flat)](https://travis-ci.org/luowei/LWPusher)
[![Version](https://img.shields.io/cocoapods/v/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)
[![License](https://img.shields.io/cocoapods/l/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)
[![Platform](https://img.shields.io/cocoapods/p/LWPusher.svg?style=flat)](https://cocoapods.org/pods/LWPusher)

## 简介

LWPusher 是一个基于腾讯信鸽推送（XGPush）的 iOS 推送通知封装库，提供了简洁易用的 API 接口，帮助开发者快速集成推送功能到 iOS 应用中。

## 功能特性

- 简洁的单例模式设计，易于使用
- 完整封装腾讯信鸽推送 SDK
- 支持账号绑定和解绑
- 支持推送消息处理和自定义跳转
- 支持角标管理
- 支持 iOS 8.0 及以上系统
- 完整的推送代理方法实现
- 支持前台和后台推送通知
- Debug 模式日志输出

## 系统要求

- iOS 8.0 或更高版本
- Xcode 开发环境
- CocoaPods 包管理工具

## 安装

LWPusher 可以通过 [CocoaPods](https://cocoapods.org) 进行安装。

### CocoaPods 安装

在你的 Podfile 中添加以下内容：

```ruby
pod 'LWPusher'
```

然后执行：

```bash
pod install
```

## 使用方法

### 1. 基本配置

在 AppDelegate 中导入头文件：

```objective-c
#import "LWPushManager.h"
```

### 2. 初始化推送服务

在 `application:didFinishLaunchingWithOptions:` 方法中配置并启动推送服务：

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 配置 AppID 和 AppKey
    [[LWPushManager shareManager] configAppID:你的AppID appKey:@"你的AppKey"];

    // 处理启动时的推送
    [[LWPushManager shareManager] handPushInApplicationDidFinishLaunchingWithOptions:launchOptions];

    return YES;
}
```

### 3. 注册远程推送

```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 设备 Token 会自动被 XGPush SDK 处理
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册远程推送失败: %@", error);
}
```

### 4. 处理推送消息

```objective-c
// iOS 10 以下版本
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // 清除角标
    application.applicationIconBadgeNumber = 0;

    // 处理推送消息
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];
}

// iOS 10 及以上版本（支持后台推送）
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    // 清除角标
    application.applicationIconBadgeNumber = 0;

    // 处理推送消息
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];

    completionHandler(UIBackgroundFetchResultNewData);
}
```

### 5. 账号绑定与解绑

```objective-c
// 绑定账号（用于单推）
[[LWPushManager shareManager] bindAccount:@"用户账号"];

// 解绑账号
[[LWPushManager shareManager] unbindAccount:@"用户账号"];
```

### 6. 启动和停止推送服务

```objective-c
// 启动推送服务
[[LWPushManager shareManager] startXGPush];

// 停止推送服务
[[LWPushManager shareManager] stopXGPush];
```

## API 说明

### LWPushManager

#### 属性

- `appID` - 腾讯信鸽推送分配的应用 ID
- `appKey` - 腾讯信鸽推送分配的应用 Key

#### 方法

##### 单例方法

```objective-c
+ (instancetype)shareManager;
```

获取 LWPushManager 的单例对象。

##### 配置方法

```objective-c
- (instancetype)configAppID:(uint32_t)appID appKey:(NSString *)appKey;
```

配置应用的 AppID 和 AppKey。

**参数：**
- `appID`: 腾讯信鸽推送分配的应用 ID
- `appKey`: 腾讯信鸽推送分配的应用 Key

**返回值：** 返回 LWPushManager 实例，支持链式调用

##### 推送服务控制

```objective-c
- (void)startXGPush;
```

启动信鸽推送服务。

```objective-c
- (void)stopXGPush;
```

停止信鸽推送服务。

##### 账号管理

```objective-c
- (void)bindAccount:(NSString *)account;
```

绑定账号，用于实现单账号推送。

**参数：**
- `account`: 用户账号标识

```objective-c
- (void)unbindAccount:(NSString *)account;
```

解绑账号。

**参数：**
- `account`: 用户账号标识

##### 推送处理

```objective-c
- (void)handPushInApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
```

在应用启动时处理推送消息。

**参数：**
- `launchOptions`: 应用启动参数字典

```objective-c
- (void)handRemotePushNotificationWithUserInfo:(NSDictionary *)userInfo;
```

处理接收到的推送消息。如果推送数据中包含 `url` 字段，会自动打开对应的 URL。

**参数：**
- `userInfo`: 推送消息的用户信息字典

## 推送消息格式

### 自定义跳转

推送消息的 `userInfo` 中可以包含 `url` 字段，用于实现自定义跳转：

```json
{
  "url": "https://example.com/page",
  "title": "推送标题",
  "content": "推送内容"
}
```

当用户点击推送消息时，应用会自动打开指定的 URL。

## 证书配置

### PEM 证书生成

使用以下命令从 p12 文件生成 PEM 证书：

```bash
# 生产环境证书
openssl pkcs12 -in aps.p12 -out aps.pem -nodes

# 开发环境证书
openssl pkcs12 -in aps_development.p12 -out aps_development.pem -nodes
```

### 配置步骤

1. 在苹果开发者中心创建推送证书
2. 下载证书并导出为 .p12 文件
3. 使用上述命令转换为 .pem 文件
4. 在腾讯信鸽推送管理后台上传 .pem 证书

## 依赖框架

LWPusher 依赖以下系统框架：

- Foundation.framework
- UIKit.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- UserNotifications.framework (弱引用)
- libsqlite3.tbd
- libz.tbd

这些框架会在通过 CocoaPods 安装时自动添加。

## 示例项目

示例项目演示了如何在实际应用中使用 LWPusher。

### 运行示例项目

1. 克隆仓库到本地
2. 进入 Example 目录
3. 执行 `pod install`
4. 打开 `LWPusher.xcworkspace`
5. 修改配置文件中的 AppID 和 AppKey
6. 运行项目

```bash
git clone https://gitlab.com/ioslibraries1/liblwpusher.git
cd liblwpusher/Example
pod install
open LWPusher.xcworkspace
```

## 调试模式

在 Debug 模式下，LWPushManager 会输出详细的日志信息，帮助开发者调试推送功能。日志宏定义如下：

```objective-c
#ifdef DEBUG
#define PushLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define PushLog(...)
#endif
```

在 Release 模式下，所有推送日志会被自动禁用。

## 注意事项

1. **真机测试**: iOS 推送功能必须在真机上测试，模拟器不支持远程推送
2. **证书配置**: 确保在腾讯信鸽推送后台正确配置了推送证书
3. **权限申请**: 首次使用时需要用户授权推送权限
4. **Bundle ID**: 应用的 Bundle ID 必须与推送证书的 Bundle ID 一致
5. **网络环境**: 推送功能需要设备联网才能正常工作
6. **账号绑定**: 使用账号绑定功能前，确保推送服务已成功启动

## 常见问题

### 1. 推送无法收到？

检查以下几点：
- 确认设备已联网
- 确认应用已获得推送权限
- 确认推送证书配置正确
- 确认 AppID 和 AppKey 配置正确
- 查看控制台日志是否有错误信息

### 2. 模拟器提示错误？

iOS 模拟器不支持远程推送功能，必须在真机上测试。错误代码 3010 表示在模拟器上运行。

### 3. 账号绑定失败？

确保：
- 推送服务已成功启动
- 设备已成功注册 Device Token
- 账号字符串不为空

### 4. 推送消息无法跳转？

检查推送消息的 `userInfo` 中是否包含有效的 `url` 字段，URL 格式是否正确。

## 技术支持

### 相关链接

- [CocoaPods 主页](https://cocoapods.org/pods/LWPusher)
- [项目仓库](https://gitlab.com/ioslibraries1/liblwpusher.git)
- [腾讯信鸽推送官网](https://xg.qq.com/)

### 问题反馈

如果在使用过程中遇到问题，可以通过以下方式联系：

- 提交 Issue 到 GitLab 仓库
- 发送邮件到: luowei@wodedata.com

## 版本历史

### v1.0.0

- 初始版本发布
- 支持基本的推送功能
- 支持账号绑定和解绑
- 支持自定义 URL 跳转
- 集成腾讯信鸽推送 SDK

## 作者

**luowei**

- Email: luowei@wodedata.com

## 许可证

LWPusher 使用 MIT 许可证开源。详细信息请查看 [LICENSE](LICENSE) 文件。

```
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

## 致谢

感谢腾讯信鸽推送团队提供的推送服务支持。
