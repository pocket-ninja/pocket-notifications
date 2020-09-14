Pod::Spec.new do |s|
  s.name             = 'PocketNotifications'
  s.version          = '0.0.2'
  s.summary          = 'The Pocket Ninja Notifications client.'

  s.homepage         = 'https://github.com/pocket-ninja/pocket-notifications'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egor mihneivch' => 'cursed.elfenlaid@gmail.com' }
  s.source           = { :git => 'git@github.com:pocket-ninja/pocket-notifications.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.2'
  s.static_framework = true

  s.source_files = 'PocketNotifications/Sources/**/*'

  s.dependency 'RxSwift', '~> 5'
  s.dependency 'RxRelay'
end
