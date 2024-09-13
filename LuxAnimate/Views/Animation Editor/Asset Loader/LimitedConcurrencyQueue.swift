//
//  LimitedConcurrencyQueue.swift
//

import Foundation

actor LimitedConcurrencyQueue {
    
    private var queue: [CheckedContinuation<Void, Error>] = []
    private var runningOperationCount = 0
    
    private let maxConcurrentOperations: Int
    
    init(maxConcurrentOperations: Int) {
        self.maxConcurrentOperations = maxConcurrentOperations
    }
    
    func enqueue(
        _ operation: @escaping () async throws -> Void
    ) async throws {
        
        if runningOperationCount >= maxConcurrentOperations {
            try await withCheckedThrowingContinuation { continuation in
                queue.append(continuation)
            }
        }
        
        runningOperationCount += 1
        defer {
            runningOperationCount -= 1
            if let next = queue.first {
                queue.removeFirst()
                next.resume()
            }
        }
        
        try await operation()
    }
    
}
