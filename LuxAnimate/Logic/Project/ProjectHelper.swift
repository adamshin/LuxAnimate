//
//  ProjectHelper.swift
//

import Foundation

struct ProjectHelper {
    
    static func drawingForFrame(
        drawings: [Project.Drawing],
        frameIndex: Int
    ) -> Project.Drawing? {
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        return sortedDrawings.last {
            $0.frameIndex <= frameIndex
        }
    }
    
}
