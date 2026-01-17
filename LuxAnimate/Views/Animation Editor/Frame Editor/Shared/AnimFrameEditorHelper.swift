//
//  AnimFrameEditorHelper.swift
//

import Foundation

struct AnimFrameEditorHelper {
    
    // MARK: - Drawings
    
    struct ActiveDrawingManifest {
        var activeDrawing: Scene.Drawing?
        var prevOnionSkinDrawings: [Scene.Drawing]
        var nextOnionSkinDrawings: [Scene.Drawing]
    }
    
    static func activeDrawingManifest(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?
    ) -> ActiveDrawingManifest {
        
        let drawings = layerContent.drawings
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let activeDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= frameIndex
        }
        
        var activeDrawing: Scene.Drawing?
        var prevOnionSkinDrawings: [Scene.Drawing] = []
        var nextOnionSkinDrawings: [Scene.Drawing] = []
        
        if let activeDrawingIndex {
            activeDrawing = sortedDrawings[activeDrawingIndex]
            
            if let onionSkinConfig {
                var prevDrawingIndex = activeDrawingIndex
                for _ in 0 ..< onionSkinConfig.prevCount {
                    prevDrawingIndex -= 1
                    if sortedDrawings.indices.contains(prevDrawingIndex) {
                        let drawing = sortedDrawings[prevDrawingIndex]
                        prevOnionSkinDrawings.append(drawing)
                    }
                }
                
                var nextDrawingIndex = activeDrawingIndex
                for _ in 0 ..< onionSkinConfig.nextCount {
                    nextDrawingIndex += 1
                    if sortedDrawings.indices.contains(nextDrawingIndex) {
                        let drawing = sortedDrawings[nextDrawingIndex]
                        nextOnionSkinDrawings.append(drawing)
                    }
                }
            }
        }
        
        return ActiveDrawingManifest(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
    }
    
    // MARK: - Assets
    
    static func assetIDs(
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: ActiveDrawingManifest
    ) -> Set<String> {
        var assetIDs = Set<String>()
        
        // Collect asset IDs from frame scene graph layers
        for layer in frameSceneGraph.layers {
            switch layer.content {
            case .drawing(let content):
                if let assetID = content.drawing.fullAssetID {
                    assetIDs.insert(assetID)
                }
            }
        }
        
        // Collect asset IDs from active drawing
        if let assetID = activeDrawingManifest.activeDrawing?.fullAssetID {
            assetIDs.insert(assetID)
        }
        
        // Collect asset IDs from onion skin drawings
        for drawing in activeDrawingManifest.prevOnionSkinDrawings {
            if let assetID = drawing.fullAssetID {
                assetIDs.insert(assetID)
            }
        }
        
        for drawing in activeDrawingManifest.nextOnionSkinDrawings {
            if let assetID = drawing.fullAssetID {
                assetIDs.insert(assetID)
            }
        }
        
        return assetIDs
    }
    
}
