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
        animationLayerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> ActiveDrawingManifest {
        
        let drawings = animationLayerContent.drawings
        
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
        
        return ActiveDrawingManifest(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
    }
    
    // MARK: - Assets
    
    struct AssetManifest {
        var activeDrawingAssetID: String?
        var otherAssetIDs: Set<String>
        
        func allAssetIDs() -> Set<String> {
            var assetIDs = otherAssetIDs
            if let activeDrawingAssetID {
                assetIDs.insert(activeDrawingAssetID)
            }
            return assetIDs
        }
    }
    
    static func assetManifest(
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: ActiveDrawingManifest
    ) -> AssetManifest {
        
        let activeDrawingAssetID = activeDrawingManifest
            .activeDrawing?.assetIDs?.full
        
        var drawings: [Scene.Drawing] = []
        
        for layer in frameSceneGraph.layers {
            switch layer.content {
            case .drawing(let content):
                drawings.append(content.drawing)
            }
        }
        
        drawings.append(contentsOf: 
            activeDrawingManifest.prevOnionSkinDrawings)
        drawings.append(contentsOf: 
            activeDrawingManifest.nextOnionSkinDrawings)
        
        var otherAssetIDs = Set<String>()
        for drawing in drawings {
            if let fullAssetID = drawing.assetIDs?.full {
                otherAssetIDs.insert(fullAssetID)
            }
        }
        if let activeDrawingAssetID {
            otherAssetIDs.remove(activeDrawingAssetID)
        }
        
        return AssetManifest(
            activeDrawingAssetID: activeDrawingAssetID,
            otherAssetIDs: otherAssetIDs)
    }
    
}
