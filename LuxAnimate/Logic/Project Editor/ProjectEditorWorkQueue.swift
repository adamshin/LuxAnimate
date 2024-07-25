//
//  ProjectEditorWorkQueue.swift
//

import Foundation

class ProjectEditorWorkQueue {
    
    private let queue = DispatchQueue(
        label: "ProjectEditorWorkQueue.queue",
        qos: .userInitiated)
    
    func enqueueSync(
        task: @escaping () throws -> Void
    ) throws {
        let taskSemaphore = DispatchSemaphore(value: 0)
        var taskError: Error?
        
        queue.async {
            do {
                try task()
            } catch {
                taskError = error
            }
            taskSemaphore.signal()
        }
        taskSemaphore.wait()
        
        if let taskError {
            throw taskError
        }
    }
    
}
