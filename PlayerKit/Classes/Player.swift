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
/// - loading: The player is loading or buffering
/// - ready: The player is ready for playback
/// - failed: The player has failed
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
    func playerDidPlaytoEnd(player: Player)
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
    
    var hasPlayToEnd: Bool { get }
    
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
    var fillMode: FillMode { get set }
}

@objc public enum FillMode: Int
{
    case fit
    case fill
}

/// The metadata that should be attached to any type of text track.
@objc public protocol TextTrackMetadata
{
    var displayName: String { get }
    var locale: Locale? { get }
    // Indicates that the text track represents subtitles for the def and hard of hearing (SDH).
    var isSDHTrack: Bool { get }
    
    @objc(displayNameWithLocale:) func displayName(with locale: Locale) -> String
}

extension TextTrackMetadata
{
    public func matches(_ other: TextTrackMetadata) -> Bool
    {
        return (self.locale == other.locale && self.isSDHTrack == other.isSDHTrack)
    }
}

/// A player that conforms to the TextTrackCapable protocol is capable of advertising and displaying text tracks.
@objc public protocol TextTrackCapable
{
    var selectedTextTrack: TextTrackMetadata? { get }
    var availableTextTracks: [TextTrackMetadata] { get }
    
    func fetchTextTracks(completion: @escaping ([TextTrackMetadata], TextTrackMetadata?) -> Void)
    func select(_ textTrack: TextTrackMetadata?)
}

#if os(iOS)
/// A player that adopts the ProvidesView protocol is capable of Picture in Picture playback.
@objc public protocol PictureInPictureCapable
{
    @available(iOS 9.0, *)
    var pictureInPictureController: AVPictureInPictureController? { get }
}
#endif
