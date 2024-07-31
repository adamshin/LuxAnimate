//
//  AnimationEditor.swift
//

import Foundation

protocol AnimationLayerEditorDelegate: AnyObject {
    
    func onRequestApplyEdit(
        _ editor: AnimationLayerEditor,
        edit: AnimationLayerEditor.Edit)
    
}

extension AnimationLayerEditor {
    
    struct Edit {
        var layerID: String
        var newAnimationLayerContent: Scene.AnimationLayerContent
        var newAssets: [ProjectEditor.Asset]
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
    
    func createDrawing(
        frameIndex: Int
    ) {
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
    
}
