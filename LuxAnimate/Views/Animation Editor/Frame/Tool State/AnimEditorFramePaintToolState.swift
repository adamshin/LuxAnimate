//
//  AnimEditorFramePaintToolState.swift
//

import Foundation
import BrushEngine

class AnimEditorFramePaintToolState:
    AnimEditorFrameToolState {
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        // TODO: Allow switching brushes
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.paintBrushIDs.first!)
        
        scale = AnimEditorToolSettingsStore
            .brushToolScale
        smoothing = AnimEditorToolSettingsStore
            .brushToolSmoothing
    }
    
}
