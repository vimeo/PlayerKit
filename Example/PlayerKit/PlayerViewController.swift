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
        static let VideoURL = URL(string: "https://develop-file-jello.jkos.com/download/eb4eaec0a47425221489417c92e6d3130b0106000282e18700000000020100ca")!
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

        self.player.set(AVURLAsset(url: Constants.VideoURL))
    }
    
    // MARK: Setup
    
    private func addPlayerToView()
    {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
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
    
    func playerDidUpdateState(player: Player, previousState: PlayerState)
    {
        self.activityIndicator.isHidden = true
        
        switch player.state
        {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player)
    {
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false
        {
            self.slider.value = Float(ratio)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = Int((player.bufferedTime / player.duration) * 100)
        
        self.label.text = "Buffer: \(ratio)%"
    }
    
    func playerDidPlaytoEnd(player: Player) {
        player.seek(to: 0)
    }
    
}
