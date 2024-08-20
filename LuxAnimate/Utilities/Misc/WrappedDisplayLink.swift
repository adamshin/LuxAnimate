//
//  WrappedDisplayLink.swift
//

import Foundation
import QuartzCore

class WrappedDisplayLink {
    
    typealias Callback = (CFTimeInterval) -> Void
    
    private var displayLink: CADisplayLink?
    
    fileprivate var callback: Callback = { _ in }
    
    init() {
        displayLink = CADisplayLink(
            target: WeakWrapper(self),
            selector: #selector(WeakWrapper.callback))
        
        displayLink?.add(to: .current, forMode: .common)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    func setCallback(_ callback: @escaping Callback) {
        self.callback = callback
    }
    
}

private class WeakWrapper {
    
    weak var wrapped: WrappedDisplayLink?
    
    init(_ wrapped: WrappedDisplayLink) {
        self.wrapped = wrapped
    }
    
    @objc func callback(_ displayLink: CADisplayLink) {
        wrapped?.callback(displayLink.timestamp)
    }
    
}
