//
//  MetalInterface.swift
//

import Metal

struct MetalInterface {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
    }
    
}
