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
    case unknown
    case loading
    
    private static let Domain = "com.vimeo.PlayerKit"
    
    func error() -> NSError
    {
        switch self
        {
        case .unknown:
            
            return NSError(domain: self.dynamicType.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
            
        case .loading:
            
            return NSError(domain: self.dynamicType.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: "An error occurred while loading the content."])
        }
    }
}

public enum PlayerState: Int
{
    case Loading
    case Ready
    case Failed
}

public protocol PlayerDelegate: class
{
    func playerDidUpdateState(player player: Player, previousState: PlayerState)
    func playerDidUpdatePlaying(player player: Player)
    func playerDidUpdateTime(player player: Player)
    func playerDidUpdateBufferedTime(player player: Player)
}

public protocol Player: class
{
    weak var delegate: PlayerDelegate? { get set }
    
    var state: PlayerState { get }
    
    var duration: NSTimeInterval { get }
    
    var time: NSTimeInterval { get }
    
    var bufferedTime: NSTimeInterval { get }
    
    var playing: Bool { get }
    
    var error: NSError? { get }
    
    func seek(to time: NSTimeInterval)
    
    func play()
    
    func pause()
}

// MARK: Identity Protocols

public protocol ProvidesView
{
    var view: UIView { get }
}

// MARK: Capability Protocols

public protocol AirPlayCapable
{
    var isAirPlayEnabled: Bool { get set }
}

public protocol VolumeCapable
{
    var volume: Float { get set }
}

public protocol FillModeCapable
{
    var fillMode: String { get set }
}

#if os(iOS)
public protocol PictureInPictureCapable
{
    @available(iOS 9.0, *)
    var pictureInPictureController: AVPictureInPictureController? { get }
}
#endif
