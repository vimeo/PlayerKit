//
//  AVPlayer+Utilities.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import Foundation
import AVFoundation

extension AVPlayer {
    var errorForPlayerOrItem: NSError? {
        // First try to return the current item's error
        
        if let error = self.currentItem?.error {
            // If current item's error has an underlying error, return that
            
            if let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError {
                return underlyingError
            }
            else {
                return error as NSError?
            }
        }
        
        // Otherwise, try to return the player error
        
        if let error = self.error {
            return error as NSError?
        }
        
        // An error cannot be found
        
        return nil
    }
}
