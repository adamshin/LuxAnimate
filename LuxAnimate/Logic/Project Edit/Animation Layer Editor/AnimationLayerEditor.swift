//
//  AnimationEditor.swift
//

import Foundation

// TODO: Replace this or refactor? Should this be a helper
// object that just creates edit objects? Or should it
// contain state, like the animation layer content?

protocol AnimationLayerEditorDelegate: AnyObject {
    
    func onRequestApplyEdit(
        _ editor: AnimationLayerEditor,
        edit: AnimationLayerEditor.Edit)
    
}

extension AnimationLayerEditor {
    
    struct Edit {
        var layerID: String
        var newAnimationLayerContent: Scene.AnimationLayerContent
        var newAssets: [ProjectEditManager.NewAsset]
    }
    
}

class AnimationLayerEditor {
    
    weak var delegate: AnimationLayerEditorDelegate?
    
    private let layerID: String
    private var animationLayerContent: Scene.AnimationLayerContent?
    
    init(layerID: String) {
        self.layerID = layerID
    }
    
    func update(animationLayerContent: Scene.AnimationLayerContent) {
        self.animationLayerContent = animationLayerContent
    }
    
    func createDrawing(at frameIndex: Int) {
        guard var animationLayerContent
        else { return }
        
        guard !animationLayerContent.drawings
            .contains(where: { $0.frameIndex == frameIndex })
        else { return }
        
        let drawing = Scene.Drawing(
            id: IDGenerator.id(),
            frameIndex: frameIndex,
            assetIDs: nil)
        
        animationLayerContent.drawings.append(drawing)
        
        self.animationLayerContent = animationLayerContent
        
        delegate?.onRequestApplyEdit(self,
            edit: Edit(
                layerID: layerID,
                newAnimationLayerContent: animationLayerContent,
                newAssets: []))
    }
    
    func deleteDrawing(at frameIndex: Int) {
        guard var animationLayerContent
        else { return }
        
        var drawings = animationLayerContent.drawings
        drawings = drawings.filter { $0.frameIndex != frameIndex }
        animationLayerContent.drawings = drawings
        
        self.animationLayerContent? = animationLayerContent
        
        delegate?.onRequestApplyEdit(self,
            edit: Edit(
                layerID: layerID,
                newAnimationLayerContent: animationLayerContent,
                newAssets: []))
    }
    
    func insertSpacing(at frameIndex: Int) {
        guard var animationLayerContent
        else { return }
        
        var drawings = animationLayerContent.drawings
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndex {
                drawings[index].frameIndex += 1
            }
        }
        
        animationLayerContent.drawings = drawings
        
        self.animationLayerContent? = animationLayerContent
        
        delegate?.onRequestApplyEdit(self,
            edit: Edit(
                layerID: layerID,
                newAnimationLayerContent: animationLayerContent,
                newAssets: []))
    }
    
    func removeSpacing(at frameIndex: Int) {
        guard var animationLayerContent
        else { return }
        
        var drawings = animationLayerContent.drawings
        
        let frameIndexToRemove: Int?
        if !drawings.contains(
            where: { $0.frameIndex == frameIndex })
        {
            frameIndexToRemove = frameIndex
        } else if !drawings.contains(
            where: { $0.frameIndex == frameIndex + 1 })
        {
            frameIndexToRemove = frameIndex + 1
        } else {
            frameIndexToRemove = nil
        }
        guard let frameIndexToRemove else { return }
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndexToRemove {
                drawings[index].frameIndex -= 1
            }
        }
        
        animationLayerContent.drawings = drawings
        
        self.animationLayerContent? = animationLayerContent
        
        delegate?.onRequestApplyEdit(self,
            edit: Edit(
                layerID: layerID,
                newAnimationLayerContent: animationLayerContent,
                newAssets: []))
    }
    
}
