//
//  AnimEditorFrameToolState.swift
//

protocol AnimEditorFrameToolState: AnyObject { }

class AnimEditorFrameToolStateManager {
    
    private(set) var toolState: AnimEditorFrameToolState?
    
    func update(tool: AnimEditorFrameVC.Tool) {
        switch tool {
        case .paint:
            toolState = AnimEditorFramePaintToolState()
        case .erase:
            toolState = nil
        }
    }
    
}
