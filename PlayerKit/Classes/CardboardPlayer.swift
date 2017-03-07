//
//  CardboardPlayer.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import UIKit
import Foundation
import AVFoundation

class CardboardPlayer: NSObject/*, VideoPlayer, ProvidesView, GVRVideoViewDelegate*/
{
//    @objc enum Type: Int
//    {
//        case Monoscopic
//        case Stereoscopic
//        
//        private func cardboardType() -> GVRVideoType
//        {
//            switch self
//            {
//            case .Monoscopic:
//                
//                return .Mono
//                
//            default:
//                
//                return .StereoOverUnder
//            }
//        }
//    }
//    
//    @objc enum Mode: Int
//    {
//        case Regular
//        case Headset
//        
//        private func cardboardMode() -> GVRWidgetDisplayMode
//        {
//            switch self
//            {
//            case .Regular:
//                
//                return GVRWidgetDisplayMode.Embedded
//                
//            case .Headset:
//                
//                return GVRWidgetDisplayMode.FullscreenVR
//            }
//        }
//        
//        private init(cardboardMode: GVRWidgetDisplayMode)
//        {
//            switch cardboardMode
//            {
//            case .Embedded, .Fullscreen:
//                
//                self = .Regular
//                
//            case .FullscreenVR:
//                
//                self = .Headset
//            }
//        }
//    }
//    
//    private struct Constants
//    {
//        static let BufferObserverTimeInterval: NSTimeInterval = 0.1
//    }
//    
//    // MARK: Public API
//    
//    func set(url url: NSURL, type: Type)
//    {
//        self.cardboardView.loadFromUrl(url, ofType: type.cardboardType())
//        
//        self.state = .Loading
//    }
//    
//    var mode: Mode
//        {
//        get
//        {
//            return Mode(cardboardMode: self.cardboardView.displayMode)
//        }
//        set
//        {
//            self.cardboardView.displayMode = newValue.cardboardMode()
//        }
//    }
//    
//    // MARK: ProvidesView
//    
//    private(set) var view: UIView = GVRVideoView(frame: .zero)
//    
//    private var cardboardView: GVRVideoView
//    {
//        return self.view as! GVRVideoView
//    }
//    
//    // MARK: VideoPlayer
//    
//    weak var delegate: VideoPlayerDelegate?
//    
//    var state: VideoPlayerState = .Ready
//        {
//        didSet
//        {
//            // If the player failed, set an error manually since Cardboard doesn't provide one on failure. Otherwise set it to nil.
//            
//            self.error = self.state == .Failed ? VideoPlayerError.loading.error() : nil
//            
//            self.delegate?.videoPlayerDidUpdateState(videoPlayer: self, previousState: oldValue)
//        }
//    }
//    
//    var duration: NSTimeInterval
//    {
//        return self.cardboardView.duration()
//    }
//    
//    var time: NSTimeInterval = 0
//        {
//        didSet
//        {
//            self.delegate?.videoPlayerDidUpdateTime(videoPlayer: self)
//        }
//    }
//    
//    var bufferedTime: NSTimeInterval = 0
//        {
//        didSet
//        {
//            self.delegate?.videoPlayerDidUpdateBufferedTime(videoPlayer: self)
//        }
//    }
//    
//    var playing: Bool = false
//        {
//        didSet
//        {
//            self.delegate?.videoPlayerDidUpdatePlaying(videoPlayer: self)
//        }
//    }
//    
//    private(set) var error: NSError?
//    
//    func seek(to time: NSTimeInterval)
//    {
//        self.cardboardView.seekTo(time)
//    }
//    
//    func play()
//    {
//        self.cardboardView.play()
//        
//        self.playing = true
//    }
//    
//    func pause()
//    {
//        self.cardboardView.pause()
//        
//        self.playing = false
//    }
//    
//    // MARK: Lifecycle
//    
//    override init()
//    {
//        super.init()
//        
//        self.cardboardView.delegate = self
//        
//        self.cardboardView.enableTouchTracking = true;
//        self.cardboardView.enableInfoButton = false;
//        self.cardboardView.enableFullscreenButton = false;
//        self.cardboardView.enableCardboardButton = false;
//    }
//    
//    // MARK: GVRVideoViewDelegate
//    
//    func videoView(videoView: GVRVideoView!, didUpdatePosition position: NSTimeInterval)
//    {
//        self.time = position
//        
//        // Stop playing if we're at the end of video
//        
//        if self.time >= self.duration
//        {
//            self.pause()
//        }
//        
//        if self.playing == false
//        {
//            // This is a fix for a bug in the Cardboard SDK. Sometimes the video video will start playing on its own (usually while seeking).
//            
//            self.pause()
//        }
//    }
//    
//    func widgetView(widgetView: GVRWidgetView!, didFailToLoadContent content: AnyObject!, withErrorMessage errorMessage: String!)
//    {
//        self.state = .Failed
//    }
//    
//    func widgetView(widgetView: GVRWidgetView!, didLoadContent content: AnyObject!)
//    {
//        self.state = .Ready
//        
//        PlaybackAnalyticsManager.shared.log360PlaybackFormat()
//    }
//    
//    func widgetView(widgetView: GVRWidgetView!, didChangeDisplayMode displayMode: GVRWidgetDisplayMode)
//    {
//        let isStereoscopic: Bool
//        switch displayMode
//        {
//        case .Embedded:
//            isStereoscopic = false
//        case .Fullscreen:
//            isStereoscopic = false
//        case .FullscreenVR:
//            isStereoscopic = true
//            break
//        }
//        
//        PlaybackAnalyticsManager.shared.log360PlaybackFormat(isStereoscopic)
//    }
}

// MARK: Capability Protocols

//extension CardboardPlayer: VolumeCapable
//{
//    var volume: Float
//        {
//        get
//        {
//            return self.cardboardView.volume
//        }
//        set
//        {
//            self.cardboardView.volume = newValue
//        }
//    }
//}
