#
# Be sure to run `pod lib lint LWPusher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWPusher'
  s.version          = '1.0.0'
  s.summary          = 'A short description of LWPusher.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.com/ioslibraries1/liblwpusher.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://gitlab.com/ioslibraries1/liblwpusher.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LWPusher/Classes/**/*.{h,m}','LWPusher/XGPush/*.{h,m}'
  s.exclude_files = 'LWPusher/Swift/**/*.swift'

  # s.resource_bundles = {
  #   'LWPusher' => ['LWPusher/Assets/*.png']
  # }
  s.public_header_files = [
      'LWPusher/Classes/**/*.h',
      'LWPusher/Classes/XGPush/**/*.h'
  ]

  s.frameworks = 'Foundation','UIKit','CoreTelephony', 'SystemConfiguration'
  s.weak_framework = 'UserNotifications'

  s.vendored_libraries = 'LWPusher/Classes/XGPush/libXGPush.a'
  s.libraries = 'sqlite3','z',"XGPush"

  s.static_framework = true

  # s.dependency 'AFNetworking', '~> 2.3'


  # s.xcconfig = {
  #   # 'OTHER_LDFLAGS' => '$(inherited) -force_load $(SRCROOT)/LWPusher/XGPush/libXG-SDK.a'
  #   # 'OTHER_LDFLAGS' => '-force_load $(inherited)'
  #   'OTHER_LDFLAGS' => '$(inherited)'
  # }


  # 参考：
  # https://stackoverflow.com/questions/19481125/add-static-library-to-podspec
  # https://www.jianshu.com/p/5d987d82d4d9

  # s.subspec 'XGPush' do |c|
  #   c.source_files = 'LWPusher/XGPush/*.{h,m}'
  #   c.vendored_libraries = 'LWPusher/XGPush/libXG-SDK.a'
  #   c.libraries = 'XG-SDK','sqlite3','z'
  #   # c.frameworks = 'Foundation','UIKit','CoreTelephony', 'SystemConfiguration'
  #   # c.weak_framework = 'UserNotifications'
  # end

  #s.subspec 'XGPush' do |c|
  #    # c.public_header_files = 'LWPusher/XGPush/XGPush.h'
  #    # c.dependency 'AFNetworking'
  #    # c.resources = 'LWPusher/XGPush/Assets/*'
  #
  #    c.source_files = 'LWPusher/XGPush/*.{h,m}'
  #    c.preserve_paths = 'LWPusher/XGPush/*.h'
  #    c.vendored_libraries = 'LWPusher/XGPush/libXG-SDK.a'
  #    c.libraries = 'XG-SDK','sqlite3','z'
  #    c.frameworks = 'UIKit','CoreTelephony', 'SystemConfiguration'
  #
  #    # c.frameworks = 'CoreTelephony', 'SystemConfiguration','UserNotifications'
  #    # c.xcconfig = {
  #    #   'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/XGPush/**",
  #    #   'OTHER_LDFLAGS' => '$(inherited)'
  #    #   # 'OTHER_CFLAGS' => '$(inherited)'
  #    # }
  #  end


end
