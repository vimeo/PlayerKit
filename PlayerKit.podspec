#
# Be sure to run `pod lib lint PlayerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PlayerKit'
  s.version          = '0.1.0'
  s.summary          = 'A modular video player system.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  PlayerKit is a modular video player system. It provides a common interface for players and various players that implement it.
                       DESC

  s.homepage         = 'https://github.com/vimeo/PlayerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gavin King' => 'gavin@vimeo.com' }
  s.source           = { :git => 'https://github.com/vimeo/PlayerKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'PlayerKit/Classes/**/*'

  # s.resource_bundles = {
  #   'PlayerKit' => ['PlayerKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

end
