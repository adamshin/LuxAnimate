//
//  ProjectEditorWorkQueue.swift
//

import Foundation

private let maxTaskCount = 3

class ProjectEditorWorkQueue {
    
    private let queue = DispatchQueue(
        label: "ProjectEditorWorkQueue.queue",
        qos: .userInteractive)
    
    private let queueSemaphore = DispatchSemaphore(
        value: maxTaskCount)
    
    func enqueue(
        task: @escaping () -> Void
    ) {
        queueSemaphore.wait()
        queue.async {
            task()
            self.queueSemaphore.signal()
        }
    }
    
    func enqueueSync(
        task: @escaping () -> Void
    ) {
        let taskSemaphore = DispatchSemaphore(value: 0)
        
        enqueue {
            task()
            taskSemaphore.signal()
        }
        
        taskSemaphore.wait()
    }
    
}
