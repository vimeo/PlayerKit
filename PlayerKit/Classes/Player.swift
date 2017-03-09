//
//  Player.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import UIKit
import AVKit

internal enum PlayerError: Int
{
    case Unknown
    case Loading
    
    private static let Domain = "com.vimeo.PlayerKit"
    
    func error() -> NSError
    {
        switch self
        {
        case .Unknown:
            
            return NSError(domain: self.dynamicType.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
            
        case .Loading:
            
            return NSError(domain: self.dynamicType.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An error occurred while loading the content."])
        }
    }
}

/// Represents the current state of the player
///
/// - Loading: The player is loading or buffering
/// - Ready: The player is ready for playback
/// - Failed: The player has failed
public enum PlayerState: Int
{
    case Loading
    case Ready
    case Failed
}

/// An object that adopts the PlayerDelegate protocol can receive updates from the player.
public protocol PlayerDelegate: class
{
    func playerDidUpdateState(player player: Player, previousState: PlayerState)
    func playerDidUpdatePlaying(player player: Player)
    func playerDidUpdateTime(player player: Player)
    func playerDidUpdateBufferedTime(player player: Player)
}

/// An object that adopts the Player protocol is responsible for implementing the API and calling PlayerDelegate methods where appropriate.
public protocol Player: class
{
    weak var delegate: PlayerDelegate? { get set }
    
    var state: PlayerState { get }
    
    var duration: NSTimeInterval { get }
    
    var time: NSTimeInterval { get }
    
    var bufferedTime: NSTimeInterval { get }
    
    var playing: Bool { get }
    
    var error: NSError? { get }
    
    /// Seeks to the specified time
    ///
    /// - Parameter time: The specified time
    func seek(to time: NSTimeInterval)
    
    /// Play the video
    func play()
    
    /// Pause the video
    func pause()
}

// MARK: Identity Protocols

/// A player that adopts the ProvidesView protocol is capable of providing a view to be added to a view hierarchy.
public protocol ProvidesView
{
    var view: UIView { get }
}

// MARK: Capability Protocols

/// A player that adopts the ProvidesView protocol is capable of AirPlay playback.
public protocol AirPlayCapable
{
    var isAirPlayEnabled: Bool { get set }
}

/// A player that adopts the ProvidesView protocol is capable of setting audio volume.
public protocol VolumeCapable
{
    var volume: Float { get set }
}

/// A player that adopts the ProvidesView protocol is capable of setting the video fill mode.
public protocol FillModeCapable
{
    var fillMode: String { get set }
}

#if os(iOS)
/// A player that adopts the ProvidesView protocol is capable of Picture in Picture playback.
public protocol PictureInPictureCapable
{
    @available(iOS 9.0, *)
    var pictureInPictureController: AVPictureInPictureController? { get }
}
#endif
