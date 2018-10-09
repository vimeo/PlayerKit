Pod::Spec.new do |s|
  s.name             = 'PlayerKit'
  s.version          = '1.3.1'
  s.summary          = 'A modular video player system.'

  s.description      = <<-DESC
  PlayerKit is a modular video player system for iOS and tvOS.
                       DESC

  s.homepage         = 'https://github.com/kim-company/PlayerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gavin King' => 'gavin@vimeo.com' }
  s.source           = { :git => 'https://github.com/kim-company/PlayerKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'PlayerKit/Classes/**/*'

end
