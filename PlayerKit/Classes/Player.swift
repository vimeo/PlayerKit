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

@objc enum VideoPlayerState: Int
{
    case Loading
    case Ready
    case Failed
}

@objc protocol VideoPlayerDelegate: class
{
    func videoPlayerDidUpdateState(videoPlayer videoPlayer: VideoPlayer, previousState: VideoPlayerState)
    func videoPlayerDidUpdatePlaying(videoPlayer videoPlayer: VideoPlayer)
    func videoPlayerDidUpdateTime(videoPlayer videoPlayer: VideoPlayer)
    func videoPlayerDidUpdateBufferedTime(videoPlayer videoPlayer: VideoPlayer)
}

@objc protocol VideoPlayer: class
{
    weak var delegate: VideoPlayerDelegate? { get set }
    
    var state: VideoPlayerState { get }
    
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

@objc protocol ProvidesView
{
    var view: UIView { get }
}

// MARK: Capability Protocols

@objc protocol AirPlayCapable
{
    var isAirPlayEnabled: Bool { get set }
}

@objc protocol PictureInPictureCapable
{
    @available(iOS 9.0, *)
    var pictureInPictureController: AVPictureInPictureController? { get }
}

@objc protocol VolumeCapable
{
    var volume: Float { get set }
}

@objc protocol FillModeCapable
{
    var fillMode: String { get set }
}
