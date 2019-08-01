Pod::Spec.new do |s|
  s.name             = 'PlayerKit'
  s.version          = '3.0.0'
  s.summary          = 'A modular video player system.'

  s.description      = <<-DESC
  PlayerKit is a modular video player system for iOS and tvOS.
                       DESC

  s.homepage         = 'https://github.com/vimeo/PlayerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'code' => 'gavin@vimeo.com' }
  s.source           = { :git => 'https://github.com/vimeo/PlayerKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'
  s.tvos.deployment_target = '10.0'

  s.swift_version = "5.0"
  
  s.source_files = 'PlayerKit/Classes/**/*'

end
