//
//  TestFrameEditor.swift
//

import UIKit
import Metal

private let sceneSize = PixelSize(1920, 1080)
private let drawingSize = PixelSize(1000, 1000)

private let drawingTransform: Matrix3 = .identity

protocol TestFrameEditorDelegate: AnyObject {
    
    func workspaceViewSize(
        _ e: TestFrameEditor
    ) -> Size
    
    func workspaceTransform(
        _ e: TestFrameEditor
    ) -> TestWorkspaceTransform
    
    func onChangeSceneContentSize(
        _ e: TestFrameEditor)
    
    // TODO: Methods for reporting project edits
    
}

class TestFrameEditor {
    
    weak var delegate: TestFrameEditorDelegate?
    
    // TODO: Logic for loading a single frame and editing content
    
    private let toolState: TestFrameEditorToolState?
    
    // MARK: - Init
    
    // TODO: This needs to take scene/frame/layer data.
    // We'll load assets, generate an editor scene.
    
    init(
        editorToolState: TestEditorToolState,
        drawingCanvasTexture: MTLTexture?
    ) {
        switch editorToolState {
        case let state as TestEditorPaintToolState:
            let toolState = TestFrameEditorPaintToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize,
                drawingCanvasTexture: drawingCanvasTexture)
            
            self.toolState = toolState
            toolState.delegate = self
            
        case let state as TestEditorEraseToolState:
            let toolState = TestFrameEditorEraseToolState(
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
    
    private func createEditorScene() -> TestEditorScene {
        let sceneSize = Size(
            Double(sceneSize.width),
            Double(sceneSize.height))
        
        let layerSize = Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
        
        let drawingTexture = toolState?.drawingCanvasTexture()
        
        var scene = TestEditorScene(layers: [
            TestEditorScene.Layer(
                transform: .identity,
                contentSize: sceneSize,
                alpha: 1,
                content: .rect(.init(
                    color: .brushBlue
                ))
            ),
            TestEditorScene.Layer(
                transform: drawingTransform,
                contentSize: layerSize,
                alpha: 1,
                content: .rect(.init(
                    color: .white
                ))
            ),
        ])
        if let drawingTexture {
            let layer = TestEditorScene.Layer(
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
    
    func clearCanvas() {
        toolState?.clearCanvas()
    }
    
    func onFrame() -> TestEditorScene? {
        toolState?.onFrame()
        
        let scene = createEditorScene()
        return scene
    }
    
}

// MARK: - Delegates

extension TestFrameEditor: TestFrameEditorPaintToolStateDelegate {
    
    func workspaceViewSize(
        _ s: TestFrameEditorPaintToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: TestFrameEditorPaintToolState
    ) -> TestWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: TestFrameEditorPaintToolState
    ) -> Size {
        Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
    }
    
    func layerTransform(
        _ s: TestFrameEditorPaintToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}

extension TestFrameEditor: TestFrameEditorEraseToolStateDelegate {
    
    func workspaceViewSize(
        _ s: TestFrameEditorEraseToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: TestFrameEditorEraseToolState
    ) -> TestWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: TestFrameEditorEraseToolState
    ) -> Size {
        Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
    }
    
    func layerTransform(
        _ s: TestFrameEditorEraseToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}
