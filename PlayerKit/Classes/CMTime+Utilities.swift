//
//  CMTime+Utilities.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import Foundation
import AVFoundation

extension CMTime
{
    var timeInterval: TimeInterval?
    {
        if CMTIME_IS_INVALID(self) || CMTIME_IS_INDEFINITE(self)
        {
            return nil
        }
        
        return CMTimeGetSeconds(self)
    }
}

extension TimeInterval
{
    
    var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    var seconds: Int {
        return Int(self) % 60
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    var hours: Int {
        return Int(self) / 3600
    }
    
    func compareHourToSecond(interval: TimeInterval) -> Bool
    {
        if interval.seconds == self.seconds, interval.minutes == self.minutes, interval.hours == self.hours
        {
            return true
        }
        return false
    }
}
