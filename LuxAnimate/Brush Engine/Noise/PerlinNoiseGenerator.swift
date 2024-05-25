//
//  PerlinNoiseGenerator.swift
//

import Foundation

struct PerlinNoiseGenerator {
    
    private let frequency: Double
    private let persistence: Double
    private let lacunarity: Double
    
    private let seeds: [UInt64]
    
    init(
        frequency: Double,
        octaveCount: Int,
        persistence: Double = 0.5,
        lacunarity: Double = 2.0)
    {
        self.frequency = frequency
        self.persistence = persistence
        self.lacunarity = lacunarity
        
        var seeds: [UInt64] = []
        for _ in 0 ..< octaveCount {
            let seed = UInt64.random(
                in: UInt64.min ... UInt64.max)
            seeds.append(seed)
        }
        self.seeds = seeds
    }
    
    func value(at x: Double) -> Double {
        var frequency = frequency
        var scale: Double = 1.0
        
        var total: Double = 0
        var totalScale: Double = 0
        
        for seed in seeds {
            let noise = perlin1D(
                x: x * frequency,
                seed: seed)
            
            total += noise * scale
            totalScale += scale
            
            frequency *= lacunarity
            scale *= persistence
        }
        
        return total / totalScale
    }
    
}

// MARK: - Perlin Noise

private func fade(_ t: Double) -> Double {
    t * t * t * (t * (t * 6 - 15) + 10)
}

private func lerp(_ t: Double, _ a: Double, _ b: Double) -> Double {
    a + t * (b - a)
}

private func grad(_ hash: UInt64, _ x: Double) -> Double {
    return (hash & 1 == 0) ? x : -x
}

private func perlin1D(x: Double, seed: UInt64) -> Double {
    // Determine grid cell coordinates
    let cellX = UInt64(floor(x))
    
    // Relative position in the grid cell
    let xRel = x - Double(cellX)
    
    // Hash function to get pseudo-random gradients
    func hash(_ i: UInt64) -> UInt64 {
        var rng = SplitMixRandomNumberGenerator(seed: seed + i)
        return UInt64.random(in: 0...255, using: &rng)
    }
    
    // Get gradients at endpoints of the grid cell
    let g0 = hash(cellX)
    let g1 = hash(cellX + 1)
    
    // Compute noise contributions from each of the two endpoints
    let n0 = grad(g0, xRel)
    let n1 = grad(g1, xRel - 1)
    
    // Compute the fade curve for x
    let u = fade(xRel)
    
    // Interpolate the two results
    let n = lerp(u, n0, n1)
    
    return n * 2
}
