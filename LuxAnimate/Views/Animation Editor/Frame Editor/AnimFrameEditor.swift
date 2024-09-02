//
//  AnimFrameEditor.swift
//

import UIKit
import Metal

private let sceneSize = PixelSize(1920, 1080)
private let drawingSize = PixelSize(1000, 1000)

private let drawingTransform: Matrix3 = .identity

protocol AnimFrameEditorDelegate: AnyObject {
    
    func workspaceViewSize(
        _ e: AnimFrameEditor
    ) -> Size
    
    func workspaceTransform(
        _ e: AnimFrameEditor
    ) -> AnimWorkspaceTransform
    
    func onChangeSceneContentSize(
        _ e: AnimFrameEditor)
    
    // TODO: Methods for reporting project edits
    
}

class AnimFrameEditor {
    
    weak var delegate: AnimFrameEditorDelegate?
    
    // TODO: Logic for loading a single frame and editing content
    
    // TODO: Create editor scene from project data, load assets,
    // update tool state once assets are loaded
    
    private let toolState: AnimFrameEditorToolState?
    
    // MARK: - Init
    
    // TODO: This needs to take scene/frame/layer data.
    // We'll load assets, generate an editor scene.
    
    init(
        editorToolState: AnimEditorToolState,
        drawingCanvasTexture: MTLTexture?
    ) {
        switch editorToolState {
        case let state as AnimEditorPaintToolState:
            let toolState = AnimFrameEditorPaintToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize,
                drawingCanvasTexture: drawingCanvasTexture)
            
            self.toolState = toolState
            toolState.delegate = self
            
        case let state as AnimEditorEraseToolState:
            let toolState = AnimFrameEditorEraseToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize,
                drawingCanvasTexture: drawingCanvasTexture)
            
            self.toolState = toolState
            toolState.delegate = self
            
        default:
            toolState = nil
        }
    }
    
    // MARK: - Logic
    
    private func createEditorScene() -> AnimEditorScene {
        let sceneSize = Size(
            Double(sceneSize.width),
            Double(sceneSize.height))
        
        let layerSize = Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
        
        let drawingTexture = toolState?.drawingCanvasTexture()
        
        var scene = AnimEditorScene(layers: [
            AnimEditorScene.Layer(
                transform: .identity,
                contentSize: sceneSize,
                alpha: 1,
                content: .rect(.init(
                    color: .brushBlue
                ))
            ),
            AnimEditorScene.Layer(
                transform: drawingTransform,
                contentSize: layerSize,
                alpha: 1,
                content: .rect(.init(
                    color: .white
                ))
            ),
        ])
        if let drawingTexture {
            let layer = AnimEditorScene.Layer(
                transform: drawingTransform,
                contentSize: layerSize,
                alpha: 1,
                content: .drawing(.init(
                    texture: drawingTexture
                ))
            )
            scene.layers.append(layer)
        }
        return scene
    }
    
    // MARK: - Interface
    
    func sceneContentSize() -> PixelSize {
        return sceneSize
    }
    
    func drawingCanvasTexture() -> MTLTexture? {
        toolState?.drawingCanvasTexture()
    }
    
    func onFrame() -> AnimEditorScene? {
        toolState?.onFrame()
        
        let scene = createEditorScene()
        return scene
    }
    
}

// MARK: - Delegates

extension AnimFrameEditor: AnimFrameEditorPaintToolStateDelegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorPaintToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorPaintToolState
    ) -> AnimWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorPaintToolState
    ) -> Size {
        Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
    }
    
    func layerTransform(
        _ s: AnimFrameEditorPaintToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}

extension AnimFrameEditor: AnimFrameEditorEraseToolStateDelegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorEraseToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorEraseToolState
    ) -> AnimWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorEraseToolState
    ) -> Size {
        Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
    }
    
    func layerTransform(
        _ s: AnimFrameEditorEraseToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}
