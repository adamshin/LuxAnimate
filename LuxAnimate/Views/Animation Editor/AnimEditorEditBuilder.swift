//
//  AnimEditorEditBuilder.swift
//

import Foundation

extension AnimEditorEditBuilder {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestSceneEdit(
            _ b: AnimEditorEditBuilder,
            sceneEdit: ProjectEditBuilder.SceneEdit,
            editContext: Sendable?)
        
    }
    
}

@MainActor
class AnimEditorEditBuilder {
    
    
    
}
