//
//  AsyncSemaphore.swift
//

import Foundation

actor AsyncSemaphore {
    
    enum SemaphoreError: Swift.Error {
        case semaphoreDeallocated
    }
    
    private let initialValue: Int
    private var value: Int
    
    private var waitingContinuations:
        [CheckedContinuation<Void, Error>] = []
    
    init(value: Int) {
        precondition(
            value >= 0,
            "AsyncSemaphore value must be non-negative")
        
        self.initialValue = value
        self.value = value
    }
    
    deinit {
        for c in waitingContinuations {
            c.resume(throwing: SemaphoreError.semaphoreDeallocated)
        }
    }
    
    func wait() async throws {
        if value > 0 {
            value -= 1
            
        } else {
            try await withCheckedThrowingContinuation { c in
                waitingContinuations.append(c)
            }
        }
    }
    
    func signal() {
        if !waitingContinuations.isEmpty {
            precondition(
                value == 0,
                "AsyncSemaphore has non-zero value (\(value)) with waiting tasks")
            
            let c = waitingContinuations.removeFirst()
            c.resume()
            
        } else {
            value += 1
            
            precondition(
                value <= initialValue,
                "AsyncSemaphore value imbalanced. More signals than waits")
        }
    }
    
}
