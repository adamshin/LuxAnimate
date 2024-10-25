//
//  MetalInterface.swift
//

import Metal

struct MetalInterface: @unchecked Sendable {
    
    static let shared = MetalInterface()
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
    }
    
}
