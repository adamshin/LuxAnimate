//
//  MetalInterface.swift
//

import Metal

struct MetalInterface {
    
    static let shared = MetalInterface()
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
    }
    
}
