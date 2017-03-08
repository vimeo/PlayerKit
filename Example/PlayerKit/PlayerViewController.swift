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
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var player: RegularPlayer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupPlayer()
        
        let asset = AVURLAsset(URL: NSURL(string: "https://github.com/vimeo/PlayerKit/blob/master/Example/PlayerKit/video.mp4?raw=true")!)
        
        self.player?.set(asset: asset)
    }
    
    // MARK: Setup
    
    private func setupPlayer()
    {
        let player = RegularPlayer()
        
        player.delegate = self
        
        self.player = player

        // Add the player to the view
        
        player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, atIndex: 0)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPlayButton()
    {
        guard let player = self.player else
        {
            return
        }
        
        player.playing ? player.pause() : player.play()
    }
    
    @IBAction func didChangeSliderValue()
    {
        guard let duration = self.player?.duration else
        {
            return
        }
        
        let value = Double(self.slider.value)
        
        let time = value * duration
        
        self.player?.seek(to: time)
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
        if let time = self.player?.time, let duration = self.player?.duration where duration > 0
        {
            let ratio = time / duration
            
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
            
            self.label.text = "\(ratio)%"
        }
    }
}
