//
//  RegularPlayer.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import UIKit
import Foundation
import AVFoundation
import AVKit

/// A RegularPlayer is used to play regular videos.
open class RegularPlayer: NSObject, Player, ProvidesView
{
    public struct Constants
    {
        public static let TimeUpdateInterval: TimeInterval = 0.1
    }
    
    // MARK: Private Properties
    
    fileprivate var player = AVPlayer()
    
    // MARK: Public API
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    open func set(asset: AVAsset)
    {
        // Prepare the old item for removal
        
        if let currentItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: currentItem)
        }
        
        // Replace it with the new item
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.addPlayerItemObservers(toPlayerItem: playerItem)
        
        self.player.replaceCurrentItem(with: playerItem)
    }
    
    // MARK: ProvidesView
    
    fileprivate class RegularPlayerView: UIView
    {
        var playerLayer: AVPlayerLayer
        {
            return self.layer as! AVPlayerLayer
        }
        
        override class var layerClass : AnyClass
        {
            return AVPlayerLayer.self
        }
        
        func configureForPlayer(player: AVPlayer)
        {
            (self.layer as! AVPlayerLayer).player = player
        }
    }
    
    open let view: UIView = RegularPlayerView(frame: .zero)
    
    fileprivate var regularPlayerView: RegularPlayerView
    {
        return self.view as! RegularPlayerView
    }
    
    fileprivate var playerLayer: AVPlayerLayer
    {
        return self.regularPlayerView.playerLayer
    }
    
    // MARK: Player
    
    weak open var delegate: PlayerDelegate?
    
    open fileprivate(set) var state: PlayerState = .ready
    {
        didSet
        {
            self.delegate?.playerDidUpdateState(player: self, previousState: oldValue)
        }
    }
    
    open var duration: TimeInterval
    {
        return self.player.currentItem?.duration.timeInterval ?? 0
    }
    
    open fileprivate(set) var time: TimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateTime(player: self)
        }
    }
    
    open fileprivate(set) var bufferedTime: TimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateBufferedTime(player: self)
        }
    }
    
    open var playing: Bool
    {
        return self.player.rate > 0
    }
    
    open var error: NSError?
    {
        return self.player.errorForPlayerOrItem
    }
    
    open func seek(to time: TimeInterval)
    {
        let cmTime = CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC))
        
        self.player.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        self.time = time
    }
    
    open func play()
    {
        self.player.play()
    }
    
    open func pause()
    {
        self.player.pause()
    }
    
    // MARK: Lifecycle
    
    public override init()
    {
        super.init()
        
        self.addPlayerObservers()
        
        self.regularPlayerView.configureForPlayer(player: self.player)
        
        self.setupAirplay()
    }
    
    deinit
    {
        if let playerItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: playerItem)
        }
        
        self.removePlayerObservers()
    }
    
    // MARK: Setup
    
    fileprivate func setupAirplay()
    {
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    // MARK: Observers
    
    fileprivate struct KeyPath
    {
        struct Player
        {
            static let Rate = "rate"
        }
        
        struct PlayerItem
        {
            static let Status = "status"
            static let PlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
            static let LoadedTimeRanges = "loadedTimeRanges"
        }
    }
    
    fileprivate var playerTimeObserver: AnyObject?
    
    fileprivate func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
    }
    
    fileprivate func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
    }
    
    fileprivate func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.initial, .new], context: nil)
        
        let interval = CMTimeMakeWithSeconds(Constants.TimeUpdateInterval, Int32(NSEC_PER_SEC))
        
        self.playerTimeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            
            if let strongSelf = self, let time = cmTime.timeInterval
            {
                strongSelf.time = time
            }
        }) as AnyObject?
    }
    
    fileprivate func removePlayerObservers()
    {
        self.player.removeObserver(self, forKeyPath: KeyPath.Player.Rate, context: nil)
        
        if let playerTimeObserver = self.playerTimeObserver
        {
            self.player.removeTimeObserver(playerTimeObserver)
            
            self.playerTimeObserver = nil
        }
    }
    
    // MARK: Observation
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // Player Item Observers
        
        if keyPath == KeyPath.PlayerItem.Status
        {
            if let statusInt = change?[NSKeyValueChangeKey.newKey] as? Int, let status = AVPlayerItemStatus(rawValue: statusInt)
            {
                self.playerItemStatusDidChange(status: status)
            }
        }
        else if keyPath == KeyPath.PlayerItem.PlaybackLikelyToKeepUp
        {
            if let playbackLikelyToKeepUp = change?[NSKeyValueChangeKey.newKey] as? Bool
            {
                self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
        else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges
        {
            if let loadedTimeRanges = change?[NSKeyValueChangeKey.newKey] as? [NSValue]
            {
                self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
            }
        }
            
            // Player Observers
            
        else if keyPath == KeyPath.Player.Rate
        {
            if let rate = change?[NSKeyValueChangeKey.newKey] as? Float
            {
                self.playerRateDidChange(rate: rate)
            }
        }
            
            // Fall Through Observers
            
        else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Observation Helpers
    
    fileprivate func playerItemStatusDidChange(status: AVPlayerItemStatus)
    {
        switch status
        {
        case .unknown:
            
            self.state = .loading
            
        case .readyToPlay:
            
            self.state = .ready
            
        case .failed:
            
            self.state = .failed
        }
    }
    
    fileprivate func playerRateDidChange(rate: Float)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
    }
    
    fileprivate func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: Bool)
    {
        let state: PlayerState = playbackLikelyToKeepUp ? .ready : .loading
        
        self.state = state
    }
    
    fileprivate func playerItemLoadedTimeRangesDidChange(loadedTimeRanges: [NSValue])
    {
        guard let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else
        {
            return
        }
        
        self.bufferedTime = bufferedTime
    }
    
    // MARK: Capability Protocol Helpers
    
    #if os(iOS)
    @available(iOS 9.0, *)
    fileprivate lazy var _pictureInPictureController: AVPictureInPictureController? = {
        AVPictureInPictureController(playerLayer: self.regularPlayerView.playerLayer)
    }()
    #endif
}

// MARK: Capability Protocols

extension RegularPlayer: AirPlayCapable
{
    public var isAirPlayEnabled: Bool
    {
        get
        {
            return self.player.allowsExternalPlayback
        }
        set
        {
            return self.player.allowsExternalPlayback = newValue
        }
    }
}

#if os(iOS)
extension RegularPlayer: PictureInPictureCapable
{
    @available(iOS 9.0, *)
    public var pictureInPictureController: AVPictureInPictureController?
    {
        return self._pictureInPictureController
    }
}
#endif

extension RegularPlayer: VolumeCapable
{
    public var volume: Float
    {
        get
        {
            return self.player.volume
        }
        set
        {
            self.player.volume = newValue
        }
    }
}

extension RegularPlayer: FillModeCapable
{
    public var fillMode: String
    {
        get
        {
            return (self.view.layer as! AVPlayerLayer).videoGravity
        }
        set
        {
            (self.view.layer as! AVPlayerLayer).videoGravity = newValue
        }
    }
}
