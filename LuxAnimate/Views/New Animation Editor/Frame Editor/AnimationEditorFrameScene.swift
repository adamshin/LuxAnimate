//
//  AnimationEditorFrameScene.swift
//

import Foundation

struct AnimationEditorFrameScene {
    
    struct Layer {
        var transform: Matrix3
        var contentSize: PixelSize
        var content: LayerContent
    }
    
    enum LayerContent {
        case activeDrawing(ActiveDrawingLayerContent)
        case drawing(DrawingLayerContent)
    }
    
    struct ActiveDrawingLayerContent {
        var drawing: Scene.Drawing?
        var prevOnionSkinDrawings: [Scene.Drawing]
        var nextOnionSkinDrawings: [Scene.Drawing]
    }
    
    struct DrawingLayerContent {
        var drawing: Scene.Drawing?
    }
    
    var viewportSize: PixelSize
    var backgroundColor: Color
    var layers: [Layer]
    
    var activeDrawingID: String?
    
}

// MARK: - Generation

extension AnimationEditorFrameScene {
    
    static func generate(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        activeLayerID: String,
        activeFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> AnimationEditorFrameScene {
        
        var frameSceneLayers: [Layer] = []
        
        for layer in sceneManifest.layers {
            let isActiveLayer = layer.id == activeLayerID
            
            switch layer.content {
            case .animation(let animationLayerContent):
                let newLayers = frameSceneLayersFromAnimationLayer(
                    layer: layer,
                    animationLayerContent: animationLayerContent,
                    activeFrameIndex: activeFrameIndex,
                    isActiveLayer: isActiveLayer,
                    onionSkinPrevCount: onionSkinPrevCount,
                    onionSkinNextCount: onionSkinNextCount)
                
                frameSceneLayers += newLayers
            }
        }
        
        var activeDrawingID: String?
        for layer in frameSceneLayers {
            if case .activeDrawing(let content) = layer.content {
                activeDrawingID = content.drawing?.id
                break
            }
        }
        
        return AnimationEditorFrameScene(
            viewportSize: projectManifest.content.metadata.viewportSize, 
            backgroundColor: sceneManifest.backgroundColor,
            layers: frameSceneLayers,
            activeDrawingID: activeDrawingID)
    }
    
    private static func frameSceneLayersFromAnimationLayer(
        layer: Scene.Layer,
        animationLayerContent: Scene.AnimationLayerContent,
        activeFrameIndex: Int,
        isActiveLayer: Bool,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> [Layer] {
        
        let drawings = animationLayerContent.drawings
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let visibleDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= activeFrameIndex
        }
        
        var visibleDrawing: Scene.Drawing?
        
        if let visibleDrawingIndex {
            visibleDrawing = sortedDrawings[visibleDrawingIndex]
        }
        
        if isActiveLayer {
            // Active layer
            var prevOnionSkinDrawings: [Scene.Drawing] = []
            var nextOnionSkinDrawings: [Scene.Drawing] = []
            
            var prevDrawingIndex = visibleDrawingIndex ?? 0
            for _ in 0 ..< onionSkinPrevCount {
                prevDrawingIndex -= 1
                if sortedDrawings.indices.contains(prevDrawingIndex) {
                    let drawing = sortedDrawings[prevDrawingIndex]
                    prevOnionSkinDrawings.append(drawing)
                }
            }
            
            var nextDrawingIndex = visibleDrawingIndex ?? -1
            for _ in 0 ..< onionSkinNextCount {
                nextDrawingIndex += 1
                if sortedDrawings.indices.contains(nextDrawingIndex) {
                    let drawing = sortedDrawings[nextDrawingIndex]
                    nextOnionSkinDrawings.append(drawing)
                }
            }
            
            let outputLayerContent = LayerContent.activeDrawing(
                ActiveDrawingLayerContent(
                    drawing: visibleDrawing,
                    prevOnionSkinDrawings: prevOnionSkinDrawings,
                    nextOnionSkinDrawings: nextOnionSkinDrawings))
            
            let outputLayer = Layer(
                transform: .identity,
                contentSize: layer.contentSize,
                content: outputLayerContent)
            
            return [outputLayer]
            
        } else {
            // Not active layer
            let outputLayerContent = LayerContent.drawing(
                DrawingLayerContent(
                    drawing: visibleDrawing))
            
            let outputLayer = Layer(
                transform: .identity,
                contentSize: layer.contentSize,
                content: outputLayerContent)
            
            return [outputLayer]
        }
    }
    
}

// MARK: - Drawings

extension AnimationEditorFrameScene {
    
    // At some point, this may have to adapt to handle
    // different asset types (video, etc?) Might not be
    // enough to just return a list of drawings.
    func allDrawings() -> [Scene.Drawing] {
        var output: [Scene.Drawing] = []
        
        for layer in layers {
            switch layer.content {
            case .activeDrawing(let content):
                if let drawing = content.drawing {
                    output.append(drawing)
                }
                output += content.prevOnionSkinDrawings
                output += content.nextOnionSkinDrawings
                
            case .drawing(let content):
                if let drawing = content.drawing {
                    output.append(drawing)
                }
            }
        }
        
        return output
    }
    
}
