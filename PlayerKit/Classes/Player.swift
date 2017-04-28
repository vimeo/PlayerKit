//
//  Player.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import UIKit
import AVKit

/// A player error
public enum PlayerError: Int
{
    case unknown
    case loading
    
    private static let Domain = "com.vimeo.PlayerKit"
    
    /// The associated error
    ///
    /// - Returns: The error
    public func error() -> NSError
    {
        switch self
        {
        case .unknown:
            
            return NSError(domain: type(of: self).Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
            
        case .loading:
            
            return NSError(domain: type(of: self).Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An error occurred while loading the content."])
        }
    }
}

/// Represents the current state of the player
///
/// - Loading: The player is loading or buffering
/// - Ready: The player is ready for playback
/// - Failed: The player has failed
@objc public enum PlayerState: Int
{
    case loading
    case ready
    case failed
}

/// An object that adopts the PlayerDelegate protocol can receive updates from the player.
@objc public protocol PlayerDelegate: class
{
    func playerDidUpdateState(player: Player, previousState: PlayerState)
    func playerDidUpdatePlaying(player: Player)
    func playerDidUpdateTime(player: Player)
    func playerDidUpdateBufferedTime(player: Player)
}

/// An object that adopts the Player protocol is responsible for implementing the API and calling PlayerDelegate methods where appropriate.
@objc public protocol Player: class
{
    weak var delegate: PlayerDelegate? { get set }
    
    var state: PlayerState { get }
    
    var duration: TimeInterval { get }
    
    var time: TimeInterval { get }
    
    var bufferedTime: TimeInterval { get }
    
    var playing: Bool { get }
    
    var error: NSError? { get }
    
    /// Seeks to the specified time
    ///
    /// - Parameter time: The specified time
    func seek(to time: TimeInterval)
    
    /// Play the video
    func play()
    
    /// Pause the video
    func pause()
}

// MARK: Identity Protocols

/// A player that adopts the ProvidesView protocol is capable of providing a view to be added to a view hierarchy.
@objc public protocol ProvidesView
{
    var view: UIView { get }
}

// MARK: Capability Protocols

/// A player that adopts the ProvidesView protocol is capable of AirPlay playback.
@objc public protocol AirPlayCapable
{
    var isAirPlayEnabled: Bool { get set }
}

/// A player that adopts the ProvidesView protocol is capable of setting audio volume.
@objc public protocol VolumeCapable
{
    var volume: Float { get set }
}

/// A player that adopts the ProvidesView protocol is capable of setting the video fill mode.
@objc public protocol FillModeCapable
{
    var fillMode: String { get set }
}

#if os(iOS)
/// A player that adopts the ProvidesView protocol is capable of Picture in Picture playback.
@objc public protocol PictureInPictureCapable
{
    @available(iOS 9.0, *)
    var pictureInPictureController: AVPictureInPictureController? { get }
}
#endif
