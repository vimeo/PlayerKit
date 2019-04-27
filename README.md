# PlayerKit

[![CI Status](http://img.shields.io/travis/ghking/PlayerKit.svg?style=flat)](https://travis-ci.org/vimeo/PlayerKit)
[![Version](https://img.shields.io/cocoapods/v/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)
[![License](https://img.shields.io/cocoapods/l/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)
[![Platform](https://img.shields.io/cocoapods/p/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)

PlayerKit is a modular video player system for iOS and tvOS.

### Motivation

Vimeo supports various types of video and playback (360 video, Chromecast, etc.). PlayerKit allows the app to create, utilize, and interact with different types of players in an abstract way.

### Goals

- Provide an interface defining a common API and delegate callback strategy for different types of players to implement
- Allow players to define their capabilities using protocol conformance

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory.

## Minimum Requirements

- iOS 8.0 / tvOS 9.0
- Swift 4.2

## Installation

PlayerKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PlayerKit"
```

## Usage

### Using RegularPlayer

RegularPlayer is an implementation of Player used to play regular videos.

To play a video:

```swift
let player = RegularPlayer()

view.addSubview(player.view) // RegularPlayer conforms to `ProvidesView`, so we can add its view

player.set(asset: AVURLAsset(URL: "https://example.com/video.mp4"))

player.play()
```

Optionally, an object can conform to PlayerDelegate to receive updates from the player and perform actions such as UI updates. Check out the example project for an example of this.

```swift
player.delegate = delegate
```

### Creating New Types of Players

You can create your own players by creating objects that conform to the Player protocol and call the delegate methods when appropriate.

## Questions?

Post on [Stackoverflow](http://stackoverflow.com/questions/tagged/vimeo-ios) with the tag `vimeo-ios`.  Get in touch [here](https://vimeo.com/help/contact).  Interested in working at Vimeo? We're [hiring](https://vimeo.com/jobs)!

## License

PlayerKit is available under the MIT license. See the LICENSE file for more info.
