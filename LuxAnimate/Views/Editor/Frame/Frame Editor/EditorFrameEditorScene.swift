//
//  EditorFrameEditorScene.swift
//

import Foundation

struct EditorFrameEditorScene {
    
    var frameScene: FrameScene
    var activeDrawingID: String?
    
    var prevOnionSkinDrawingIDs: [String]
    var nextOnionSkinDrawingIDs: [String]
    
    var allDrawings: [Project.Drawing]
    
}

extension EditorFrameEditorScene {
    
    static func generate(
        projectManifest: Project.Manifest,
        focusedFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> EditorFrameEditorScene {
        
        // Find active drawing and onion skins
        let drawings = projectManifest
            .content.animationLayer.drawings
        
        let drawingsForFrame = Self.drawingsForFrame(
            drawings: drawings,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinPrevCount: onionSkinPrevCount,
            onionSkinNextCount: onionSkinNextCount)
        
        let activeDrawingID = drawingsForFrame.activeDrawing?.id
        
        let prevOnionSkinDrawingIDs = drawingsForFrame
            .prevOnionSkinDrawings.map { $0.id }
        
        let nextOnionSkinDrawingIDs = drawingsForFrame
            .nextOnionSkinDrawings.map { $0.id }
        
        // Generate frame scene
        let frameScene = FrameScene.generate(
            projectManifest: projectManifest,
            frameIndex: focusedFrameIndex)
                
        // Create list of drawings
        var allDrawings: [Project.Drawing] = []
        
        let drawingsFromFrameScene = Self.drawings(from: frameScene)
        allDrawings += drawingsFromFrameScene
        
        allDrawings += drawingsForFrame.prevOnionSkinDrawings
        allDrawings += drawingsForFrame.nextOnionSkinDrawings
        
        // Return result
        return EditorFrameEditorScene(
            frameScene: frameScene,
            activeDrawingID: activeDrawingID,
            prevOnionSkinDrawingIDs: prevOnionSkinDrawingIDs,
            nextOnionSkinDrawingIDs: nextOnionSkinDrawingIDs,
            allDrawings: allDrawings)
    }
    
    private struct DrawingsForFrameResult {
        var activeDrawing: Project.Drawing?
        var prevOnionSkinDrawings: [Project.Drawing]
        var nextOnionSkinDrawings: [Project.Drawing]
    }
    
    private static func drawingsForFrame(
        drawings: [Project.Drawing],
        focusedFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> DrawingsForFrameResult {
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let activeDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= focusedFrameIndex
        }
        
        var activeDrawing: Project.Drawing?
        var prevOnionSkinDrawings: [Project.Drawing] = []
        var nextOnionSkinDrawings: [Project.Drawing] = []
        
        if let activeDrawingIndex {
            activeDrawing = sortedDrawings[activeDrawingIndex]
            
            var prevDrawingIndex = activeDrawingIndex
            for _ in 0 ..< onionSkinPrevCount {
                prevDrawingIndex -= 1
                if sortedDrawings.indices.contains(prevDrawingIndex) {
                    let drawing = sortedDrawings[prevDrawingIndex]
                    prevOnionSkinDrawings.append(drawing)
                }
            }
            
            var nextDrawingIndex = activeDrawingIndex
            for _ in 0 ..< onionSkinNextCount {
                nextDrawingIndex += 1
                if sortedDrawings.indices.contains(nextDrawingIndex) {
                    let drawing = sortedDrawings[nextDrawingIndex]
                    nextOnionSkinDrawings.append(drawing)
                }
            }
        }
        
        return DrawingsForFrameResult(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
    }
    
    private static func drawings(
        from frameScene: FrameScene
    ) -> [Project.Drawing] {
        
        var result: [Project.Drawing] = []
        
        for layer in frameScene.layers {
            switch layer {
            case .drawing(let drawingLayer):
                result.append(drawingLayer.drawing)
            }
        }
        return result
    }
    
}
