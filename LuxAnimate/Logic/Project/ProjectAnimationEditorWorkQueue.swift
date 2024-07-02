//
//  ProjectAnimationEditorWorkQueue.swift
//

import Foundation

private let maxTaskCount = 3

class ProjectAnimationEditorWorkQueue {
    
    private let queue = DispatchQueue(
        label: "ProjectAnimationEditorWorkQueue.queue",
        qos: .userInteractive) // Should this be background priority?
    
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
