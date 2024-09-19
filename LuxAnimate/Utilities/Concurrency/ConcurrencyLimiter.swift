//
//  ConcurrencyLimiter.swift
//

import Foundation

actor ConcurrencyLimiter {
    
    private let semaphore: AsyncSemaphore
    
    init(limit: Int) {
        semaphore = AsyncSemaphore(value: limit)
    }
    
    func run<T: Sendable>(
        _ block: @escaping () async throws -> T
    ) async throws -> T {
        
        try Task.checkCancellation()
        
        try await semaphore.wait()
        
        do {
            try Task.checkCancellation()
            
            let value = try await block()
            
            await semaphore.signal()
            return value
            
        } catch {
            await semaphore.signal()
            throw error
        }
    }
    
}
