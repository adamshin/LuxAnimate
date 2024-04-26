//
//  BrushEngineDisplayLink.swift
//

import Foundation
import QuartzCore

class BrushEngineDisplayLink {
    
    private var displayLink: CADisplayLink?
    
    fileprivate var callback: () -> Void = { }
    
    init() {
        displayLink = CADisplayLink(
            target: WeakWrapper(self),
            selector: #selector(WeakWrapper.callback))
        
        displayLink?.add(to: .current, forMode: .default)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    func setCallback(_ callback: @escaping () -> Void) {
        self.callback = callback
    }
    
}

private class WeakWrapper {
    
    weak var wrapped: BrushEngineDisplayLink?
    
    init(_ wrapped: BrushEngineDisplayLink) {
        self.wrapped = wrapped
    }
    
    @objc func callback() {
        wrapped?.callback()
    }
    
}
