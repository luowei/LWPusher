Pod::Spec.new do |s|
  s.name             = 'LWPusher'
  s.version          = '2.0.0'
  s.summary          = 'Modern Swift/SwiftUI wrapper for XGPush (Tencent Push) SDK'

  s.description      = <<-DESC
  LWPusher is a modern Swift/SwiftUI wrapper for the XGPush (Tencent Push) SDK.
  It provides both Objective-C and Swift interfaces for easy integration of push
  notifications in iOS applications. The Swift version includes SwiftUI support
  with reactive state management and modern Swift patterns.

  Features:
  - Simple, clean API for push notification management
  - Account binding for targeted push notifications
  - Badge management
  - SwiftUI integration with @Published properties
  - Type-safe Swift enumerations and option sets
  - Combine support for reactive programming
  - Comprehensive examples for UIKit and SwiftUI
                       DESC

  s.homepage         = 'https://gitlab.com/ioslibraries1/liblwpusher.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://gitlab.com/ioslibraries1/liblwpusher.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  # Source files
  s.source_files = [
    'LWPusher/Classes/**/*.{h,m}',
    'LWPusher/Swift/**/*.swift'
  ]

  # Public headers
  s.public_header_files = [
    'LWPusher/Classes/**/*.h',
    'LWPusher/Classes/XGPush/**/*.h'
  ]

  # Frameworks
  s.frameworks = 'Foundation', 'UIKit', 'CoreTelephony', 'SystemConfiguration', 'Combine'
  s.weak_framework = 'UserNotifications', 'SwiftUI'

  # Libraries
  s.vendored_libraries = 'LWPusher/Classes/XGPush/libXGPush.a'
  s.libraries = 'sqlite3', 'z', 'XGPush'

  s.static_framework = true

  # Pod target xcconfig
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_VERSION' => '5.0'
  }
end
