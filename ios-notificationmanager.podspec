Pod::Spec.new do |s|
  s.name         = "ios-notificationmanager"
  s.version      = "0.1.0"
  s.summary      = "Sane management of iOS local notifications."
  s.homepage     = "https://github.com/mruegenberg/ios-notificationmanager"

  s.license      = 'MIT'

  s.author       = { "Marcel Ruegenberg" => "github@dustlab.com" }

  s.source       = { :git => "https://github.com/mruegenberg/ios-notificationmanager.git", :tag => "0.1.0" }

  s.platform     = :ios, '5.1'
  
  s.requires_arc = true

  s.source_files = '*.{h,m}'

  s.public_header_files = 'DLNotification.h', 'DLNotificationManager.h'

  s.frameworks  = 'CoreFoundation', 'EventKit', 'UIKit'
end
