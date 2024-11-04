
import Foundation

struct JitterGenerator {
    
    private var rng: SplitMixRandomNumberGenerator
    
    init() {
        let seed = UInt64.random(
            in: UInt64.min ... UInt64.max)
        
        rng = SplitMixRandomNumberGenerator(
            seed: seed)
    }
    
    mutating func next() -> Double {
        Double.random(in: 0...1, using: &rng)
    }
    
}
