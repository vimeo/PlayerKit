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

/// A RegularPlayer can be used to play regular videos.
public class RegularPlayer: NSObject, Player, ProvidesView
{
    private struct Constants
    {
        static let TimeInterval: NSTimeInterval = 0.1
    }
    
    // MARK: Private Properties
    
    private var player = AVPlayer()
    
    // MARK: Public API
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    public func set(asset asset: AVAsset)
    {
        // Prepare the old item for removal
        
        if let currentItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: currentItem)
        }
        
        // Replace it with the new item
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.addPlayerItemObservers(toPlayerItem: playerItem)
        
        self.player.replaceCurrentItemWithPlayerItem(playerItem)
    }
    
    // MARK: ProvidesView
    
    private class RegularPlayerView: UIView
    {
        var playerLayer: AVPlayerLayer
        {
            return self.layer as! AVPlayerLayer
        }
        
        override class func layerClass() -> AnyClass
        {
            return AVPlayerLayer.self
        }
        
        func configureForPlayer(player player: AVPlayer)
        {
            (self.layer as! AVPlayerLayer).player = player
        }
    }
    
    public let view: UIView = RegularPlayerView(frame: .zero)
    
    private var regularPlayerView: RegularPlayerView
    {
        return self.view as! RegularPlayerView
    }
    
    private var playerLayer: AVPlayerLayer
    {
        return self.regularPlayerView.playerLayer
    }
    
    // MARK: VideoPlayer
    
    weak public var delegate: PlayerDelegate?
    
    public private(set) var state: PlayerState = .Ready
    {
        didSet
        {
            self.delegate?.playerDidUpdateState(player: self, previousState: oldValue)
        }
    }
    
    public var duration: NSTimeInterval
    {
        return self.player.currentItem?.duration.timeInterval ?? 0
    }
    
    public private(set) var time: NSTimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateTime(player: self)
        }
    }
    
    public private(set) var bufferedTime: NSTimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateBufferedTime(player: self)
        }
    }
    
    public var playing: Bool
    {
        return self.player.rate > 0
    }
    
    public var error: NSError?
    {
        return self.player.errorForPlayerOrItem
    }
    
    public func seek(to time: NSTimeInterval)
    {
        let cmTime = CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC))
        
        self.player.seekToTime(cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        self.time = time
    }
    
    public func play()
    {
        self.player.play()
    }
    
    public func pause()
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
    
    private func setupAirplay()
    {
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    // MARK: Observers
    
    private struct KeyPath
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
    
    private var playerTimeObserver: AnyObject?
    
    private func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.Initial, .New], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.Initial, .New], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, options: [.Initial, .New], context: nil)
    }
    
    private func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
    }
    
    private func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.Initial, .New], context: nil)
        
        let interval = CMTimeMakeWithSeconds(Constants.TimeInterval, Int32(NSEC_PER_SEC))
        
        self.playerTimeObserver = self.player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue(), usingBlock: { [weak self] (cmTime) in
            
            if let strongSelf = self, let time = cmTime.timeInterval
            {
                strongSelf.time = time
            }
        })
    }
    
    private func removePlayerObservers()
    {
        self.player.removeObserver(self, forKeyPath: KeyPath.Player.Rate, context: nil)
        
        if let playerTimeObserver = self.playerTimeObserver
        {
            self.player.removeTimeObserver(playerTimeObserver)
            
            self.playerTimeObserver = nil
        }
    }
    
    // MARK: Observation
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        // Player Item Observers
        
        if keyPath == KeyPath.PlayerItem.Status
        {
            if let statusInt = change?[NSKeyValueChangeNewKey] as? Int, let status = AVPlayerItemStatus(rawValue: statusInt)
            {
                self.playerItemStatusDidChange(status: status)
            }
        }
        else if keyPath == KeyPath.PlayerItem.PlaybackLikelyToKeepUp
        {
            if let playbackLikelyToKeepUp = change?[NSKeyValueChangeNewKey] as? Bool
            {
                self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
        else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges
        {
            if let loadedTimeRanges = change?[NSKeyValueChangeNewKey] as? [NSValue]
            {
                self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
            }
        }
            
            // Player Observers
            
        else if keyPath == KeyPath.Player.Rate
        {
            if let rate = change?[NSKeyValueChangeNewKey] as? Float
            {
                self.playerRateDidChange(rate: rate)
            }
        }
            
            // Fall Through Observers
            
        else
        {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: Observation Helpers
    
    private func playerItemStatusDidChange(status status: AVPlayerItemStatus)
    {
        switch status
        {
        case .Unknown:
            
            self.state = .Loading
            
        case .ReadyToPlay:
            
            self.state = .Ready
            
        case .Failed:
            
            self.state = .Failed
        }
    }
    
    private func playerRateDidChange(rate rate: Float)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
    }
    
    private func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp playbackLikelyToKeepUp: Bool)
    {
        let state: PlayerState = playbackLikelyToKeepUp ? .Ready : .Loading
        
        self.state = state
    }
    
    private func playerItemLoadedTimeRangesDidChange(loadedTimeRanges loadedTimeRanges: [NSValue])
    {
        guard let bufferedCMTime = loadedTimeRanges.first?.CMTimeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else
        {
            return
        }
        
        self.bufferedTime = bufferedTime
    }
    
    // MARK: Capability Protocol Helpers
    
    #if os(iOS)
    @available(iOS 9.0, *)
    private lazy var _pictureInPictureController: AVPictureInPictureController? = {
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
