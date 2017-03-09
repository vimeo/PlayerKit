//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by King, Gavin on 3/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation

class PlayerViewController: UIViewController, PlayerDelegate
{
    private struct Constants
    {
        static let VideoURL = NSURL(string: "https://github.com/vimeo/PlayerKit/blob/master/Example/PlayerKit/video.mp4?raw=true")!
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let player = RegularPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.delegate = self

        self.addPlayerToView()
        
        self.player.set(asset: AVURLAsset(URL: Constants.VideoURL))
    }
    
    // MARK: Setup
    
    private func addPlayerToView()
    {
        player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, atIndex: 0)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPlayButton()
    {
        self.player.playing ? self.player.pause() : self.player.play()
    }
    
    @IBAction func didChangeSliderValue()
    {
        let value = Double(self.slider.value)
        
        let time = value * self.player.duration
        
        self.player.seek(to: time)
    }
    
    // MARK: VideoPlayerDelegate
    
    func playerDidUpdateState(player player: Player, previousState: PlayerState)
    {
        self.activityIndicator.hidden = true
        
        switch player.state
        {
        case .Loading:
            
            self.activityIndicator.hidden = false
            
        case .Ready:
            
            break
            
        case .Failed:
            
            NSLog("🚫 \(player.error)")
        }
    }
    
    func playerDidUpdatePlaying(player player: Player)
    {
        self.playButton.selected = player.playing
    }
    
    func playerDidUpdateTime(player player: Player)
    {
        if player.duration > 0
        {
            let ratio = player.time / player.duration
            
            if self.slider.highlighted == false
            {
                self.slider.value = Float(ratio)
            }
        }
    }
    
    func playerDidUpdateBufferedTime(player player: Player)
    {
        if player.duration > 0
        {
            let ratio = Int((player.bufferedTime / player.duration) * 100)
            
            self.label.text = "Buffer: \(ratio)%"
        }
    }
}
