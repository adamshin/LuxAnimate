//
//  EditorFrameEditorScene.swift
//

import Foundation

struct EditorFrameEditorScene {
    
    var frameScene: FrameScene
    var activeDrawingID: String?
    
    var prevOnionSkinDrawingIDs: [String]
    var nextOnionSkinDrawingIDs: [String]
    
    var allDrawings: [Scene.Drawing]
    
}

extension EditorFrameEditorScene {
    
    static func generate(
        projectManifest: Project.Manifest,
        focusedFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> EditorFrameEditorScene {
        
        fatalError()
        /*
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
         */
    }
    
    private struct DrawingsForFrameResult {
        var activeDrawing: Scene.Drawing?
        var prevOnionSkinDrawings: [Scene.Drawing]
        var nextOnionSkinDrawings: [Scene.Drawing]
    }
    
    private static func drawingsForFrame(
        drawings: [Scene.Drawing],
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
        
        var activeDrawing: Scene.Drawing?
        var prevOnionSkinDrawings: [Scene.Drawing] = []
        var nextOnionSkinDrawings: [Scene.Drawing] = []
        
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
    ) -> [Scene.Drawing] {
        
        var result: [Scene.Drawing] = []
        
        for layer in frameScene.layers {
            switch layer {
            case .drawing(let drawingLayer):
                result.append(drawingLayer.drawing)
            }
        }
        return result
    }
    
}

// TODO: Clean up and refactor this. It won't be used
// elsewhere in the project like originally planned.

struct FrameScene {
    
    var backgroundColor: Color
    var layers: [FrameSceneLayer]
    
}

enum FrameSceneLayer {
    case drawing(FrameSceneDrawingLayer)
}

struct FrameSceneDrawingLayer {
    var drawing: Scene.Drawing
}

// MARK: - Generation

extension FrameScene {
    
    static func generate(
        projectManifest: Project.Manifest,
        frameIndex: Int
    ) -> FrameScene {
        
        /*
        var layers: [FrameSceneLayer] = []
        
        let drawings = projectManifest
            .content.scene.animationLayer.drawings
        
        if let drawing = ProjectHelper.drawingForFrame(
            drawings: drawings,
            frameIndex: frameIndex)
        {
            let layer = FrameSceneLayer.drawing(
                FrameSceneDrawingLayer(
                    drawing: drawing))
            
            layers.append(layer)
        }
        
        return FrameScene(
            backgroundColor: .white,
            layers: layers)
         */
        
        return FrameScene(backgroundColor: .white, layers: [])
    }
    
}

// MARK: - Helper

private struct ProjectHelper {
    
    static func drawingForFrame(
        drawings: [Scene.Drawing],
        frameIndex: Int
    ) -> Scene.Drawing? {
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        return sortedDrawings.last {
            $0.frameIndex <= frameIndex
        }
    }
    
}

