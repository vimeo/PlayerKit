Pod::Spec.new do |s|
  s.name             = 'PlayerKit'
  s.version          = '3.1.0'
  s.summary          = 'A modular video player system.'

  s.description      = <<-DESC
  PlayerKit is a modular video player system for iOS, tvOS, & macOS.
                       DESC

  s.homepage         = 'https://github.com/vimeo/PlayerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'code' => 'gavin@vimeo.com' }
  s.source           = { :git => 'https://github.com/vimeo/PlayerKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.ios.framework = 'UIKit'
  s.osx.framework = 'AppKit'

  s.swift_version = "5.0"

  s.source_files = 'Sources/**/*.swift'

end
