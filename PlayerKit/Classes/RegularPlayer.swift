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

extension AVMediaSelectionOption: TextTrackMetadata
{
    public var isSDHTrack: Bool
    {
        return self.hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) && self.hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
    }
}

/// A RegularPlayer is used to play regular videos.
@objc open class RegularPlayer: NSObject, Player, ProvidesView
{
    public struct Constants
    {
        public static let TimeUpdateInterval: TimeInterval = 0.1
    }
    
    // MARK: Private Properties
    
    fileprivate var player = AVPlayer()
    
    // MARK: Public API
    
    @objc open func set(url: URL) {
        let asset = AVURLAsset(url: url)
        set(asset)
    }
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    @objc open func set(_ asset: AVAsset)
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
    
    private class RegularPlayerView: UIView
    {
        var playerLayer: AVPlayerLayer
        {
            return self.layer as! AVPlayerLayer
        }
        
        override class var layerClass: AnyClass
        {
            return AVPlayerLayer.self
        }
        
        func configureForPlayer(player: AVPlayer)
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
    
    // MARK: Player
    
    weak public var delegate: PlayerDelegate?
    
    public private(set) var state: PlayerState = .ready
    {
        didSet
        {
            self.delegate?.playerDidUpdateState(player: self, previousState: oldValue)
        }
    }
    
    public var duration: TimeInterval
    {
        return self.player.currentItem?.duration.timeInterval ?? 0
    }
    
    public private(set) var time: TimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateTime(player: self)
        }
    }
    
    public private(set) var bufferedTime: TimeInterval = 0
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
    
    public private(set) var hasPlayToEnd: Bool = false
    
    public var error: NSError?
    {
        return self.player.errorForPlayerOrItem
    }
    
    public func seek(to time: TimeInterval)
    {
        let cmTime = CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC))
        
        hasPlayToEnd = false
        self.player.seek(to: cmTime)
        
        self.time = time
    }
    
    public func play()
    {
        hasPlayToEnd = false
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
    
    private var playerTimeObserver: Any?
    
    private func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(playerItemDidPlayToEnd(item:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self)
    }
    
    private func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.initial, .new], context: nil)
        
        let interval = CMTimeMakeWithSeconds(Constants.TimeUpdateInterval, Int32(NSEC_PER_SEC))
        
        self.playerTimeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            
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
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // Player Item Observers
        
        if keyPath == KeyPath.PlayerItem.Status
        {
            if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItemStatus(rawValue: statusInt)
            {
                self.playerItemStatusDidChange(status: status)
            }
        }
        else if keyPath == KeyPath.PlayerItem.PlaybackLikelyToKeepUp
        {
            if let playbackLikelyToKeepUp = change?[.newKey] as? Bool
            {
                self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
        else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges
        {
            if let loadedTimeRanges = change?[.newKey] as? [NSValue]
            {
                self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
            }
        }
            
        // Player Observers
            
        else if keyPath == KeyPath.Player.Rate
        {
            if let rate = change?[.newKey] as? Float
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
    
    private func playerItemStatusDidChange(status: AVPlayerItemStatus)
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
    
    private func playerRateDidChange(rate: Float)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
    }
    
    private func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: Bool)
    {
        let state: PlayerState = playbackLikelyToKeepUp ? .ready : .loading
        
        self.state = state
    }
    
    private func playerItemLoadedTimeRangesDidChange(loadedTimeRanges: [NSValue])
    {
        guard let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else
        {
            return
        }
        
        self.bufferedTime = bufferedTime
    }
    
    // MARK: Player did play to end
    
    @objc private func playerItemDidPlayToEnd(item: AVPlayerItem) {
        hasPlayToEnd = true
        delegate?.playerDidPlaytoEnd(player: self)
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
    public var fillMode: FillMode
    {
        get
        {
            let gravity = (self.view.layer as! AVPlayerLayer).videoGravity
            
            return gravity == .resizeAspect ? .fit : .fill
        }
        set
        {
            let gravity: AVLayerVideoGravity
            
            switch newValue
            {
            case .fit:
                
                gravity = .resizeAspect
                
            case .fill:
                
                gravity = .resizeAspectFill
            }

            (self.view.layer as! AVPlayerLayer).videoGravity = gravity
        }
    }
}

extension RegularPlayer: TextTrackCapable
{
    public var selectedTextTrack: TextTrackMetadata?
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return nil
        }
        
        if #available(iOS 9.0, *)
        {
            return self.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
        }
        else
        {
            return self.player.currentItem?.selectedMediaOption(in: group)
        }
    }
    
    public var availableTextTracks: [TextTrackMetadata]
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return []
        }
        return group.options
    }
    
    public func fetchTextTracks(completion: @escaping ([TextTrackMetadata], TextTrackMetadata?) -> Void)
    {
        self.player.currentItem?.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.availableMediaCharacteristicsWithMediaSelectionOptions)]) { [weak self] in
            guard let strongSelf = self, let group = strongSelf.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
            {
                completion([], nil)
                return
            }
            if #available(iOS 9.0, *)
            {
                completion(group.options, strongSelf.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group))
            }
            else
            {
                completion(group.options, strongSelf.player.currentItem?.selectedMediaOption(in: group))
            }
        }
    }
    
    public func select(_ textTrack: TextTrackMetadata?)
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return
        }
        
        guard let track = textTrack else
        {
            self.player.currentItem?.select(nil, in: group)
            return
        }
        
        let option = group.options.first(where: { option in
            track.matches(option)
        })
        self.player.currentItem?.select(option, in: group)
    }
}
