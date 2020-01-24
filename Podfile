use_frameworks!
inhibit_all_warnings!
platform :ios, '10.3'

workspace 'PlayerKit'
project 'PlayerKit.xcodeproj'

def shared_pods
    pod 'SwiftLint', '0.25.1'
end

target 'PlayerKit-iOS' do
    platform :ios, '10.3'
    shared_pods
    target 'PlayerKit-iOSTests' do
    end
end

target 'Example' do
    shared_pods
end
