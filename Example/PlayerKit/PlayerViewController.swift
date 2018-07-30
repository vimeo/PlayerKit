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
        static let VideoURL = URL(string: "https://r6---sn-n3cgv5qc5oq-bh2se.googlevideo.com/videoplayback?requiressl=yes&initcwndbps=1743750&source=youtube&key=yt6&mime=video%2Fmp4&fvip=1&pl=23&ratebypass=yes&signature=69ABD5CAFC646BB48DC793F67639D3BC07673468.8FEE31B8DC2F1A5058A74DC1CCCEF51FDE20728B&ei=k71eW43zMNTJ4AKi8rnYAg&ip=218.236.30.16&lmt=1509157459304790&mv=m&sparams=dur%2Cei%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cexpire&mt=1532935543&itag=22&ms=au%2Conr&mn=sn-n3cgv5qc5oq-bh2se%2Csn-i3b7kn7k&dur=154.203&ipbits=0&mm=31%2C26&id=o-AKbKcgGplr9U6nCO6KNsMlZEfvEs_ODba3-PEE8_tduP&expire=1532957171&c=WEB")!
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
} 
