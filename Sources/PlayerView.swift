//
//  PlayerView.swift
//  PlayerKit
//
//  Created by Balatbat, Bryant on 12/20/17.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    public typealias PlayerView = UIView
#else
    public typealias PlayerView = NSView
#endif
