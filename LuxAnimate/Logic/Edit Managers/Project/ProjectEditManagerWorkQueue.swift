//
//  ProjectEditManagerWorkQueue.swift
//

import Foundation

class ProjectEditManagerWorkQueue {
    
    private let queue = DispatchQueue(
        label: "ProjectEditManagerWorkQueue.queue",
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
