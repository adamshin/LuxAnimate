//
//  SplitMixRandomNumberGenerator.swift
//

import Foundation

struct SplitMixRandomNumberGenerator: RandomNumberGenerator {
    
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        self.state &+= 0x9e3779b97f4a7c15
        var z: UInt64 = self.state
        z = (z ^ (z &>> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z &>> 27)) &* 0x94d049bb133111eb
        return z ^ (z &>> 31)
    }
    
}
