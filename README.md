# PlayerKit

[![CI Status](http://img.shields.io/travis/ghking/PlayerKit.svg?style=flat)](https://travis-ci.org/ghking/PlayerKit)
[![Version](https://img.shields.io/cocoapods/v/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)
[![License](https://img.shields.io/cocoapods/l/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)
[![Platform](https://img.shields.io/cocoapods/p/PlayerKit.svg?style=flat)](http://cocoapods.org/pods/PlayerKit)

PlayerKit is a modular video player system.

### Motivation

Vimeo supports various types of video and playback (360 video, Chromecast, etc.). PlayerKit allows the app to create, utilize, and interact with different types of players in an abstract way.

### Goals

- Provide an interface defining a common API and delegate callback strategy that different types of players can implement
- Allow players to define their capabilities using protocol conformance

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+ / tvOS 9.0+
- Swift 2.3 (Swift 3 support coming soon)

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

Optionally, an object can conform to PlayerDelegate to recieve updates from the player and perform actions such as UI updates. Check out the example project for an example of this.

```swift
player.delegate = delegate
```

### Creating New Types of Players

You can create your own new types of players by creating objects that conform to the Player protocol and call the delgate methods when appropriate.

## Author

Gavin King, gavin@vimeo.com

## License

PlayerKit is available under the MIT license. See the LICENSE file for more info.
