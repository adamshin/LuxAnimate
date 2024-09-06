//
//  ProjectAsyncEditManagerWorkQueue.swift
//

import Foundation

class ProjectAsyncEditManagerWorkQueue {
    
    private let queue = DispatchQueue(
        label: "ProjectAsyncEditManagerWorkQueue.queue",
        qos: .userInitiated)
    
    func enqueueTask(_ task: @escaping () throws -> Void) {
        queue.async {
            do {
                try task()
            } catch { }
        }
    }
    
    func waitForAllTasksToComplete() {
        queue.sync { }
    }
    
}
