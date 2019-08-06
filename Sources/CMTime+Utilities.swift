//
//  CMTime+Utilities.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import Foundation
import AVFoundation

extension CMTime {
    var timeInterval: TimeInterval? {
        if CMTIME_IS_INVALID(self) || CMTIME_IS_INDEFINITE(self) {
            return nil
        }
        
        return CMTimeGetSeconds(self)
    }
}
