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
    
    // TODO: Logic for loading a single frame and editing content
    
    // TODO: Create editor scene from project data, load assets,
    // update tool state once assets are loaded
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    
    private let toolState: AnimFrameEditorToolState?
    
    private var projectManifest: Project.Manifest
    private var sceneManifest: Scene.Manifest
    
    weak var delegate: AnimFrameEditorDelegate?
    
    // MARK: - Init
    
    // TODO: This needs to take scene/frame/layer data.
    // We'll load assets, generate an editor scene.
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int,
        editorToolState: AnimEditorToolState,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        
        switch editorToolState {
        case let state as AnimEditorPaintToolState:
            let toolState = AnimFrameEditorPaintToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize)
            
            self.toolState = toolState
            toolState.delegate = self
            
        case let state as AnimEditorEraseToolState:
            let toolState = AnimFrameEditorEraseToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize)
            
            self.toolState = toolState
            toolState.delegate = self
            
        default:
            toolState = nil
        }
        
        // TODO: Figure out how to update the tool state
        // when the active drawing asset is loaded. The
        // tool should start out inactive, then become
        // active once assets are loaded.
        
        // TODO: Begin loading assets!
    }
    
    // MARK: - Logic
    
    private func createEditorScene() -> AnimEditorScene {
        let sceneSize = Size(
            Double(sceneSize.width),
            Double(sceneSize.height))
        
        let layerSize = Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
        
//        let drawingTexture = toolState?.drawingCanvasTexture()
        
        let scene = AnimEditorScene(layers: [
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
//        if let drawingTexture {
//            let layer = AnimEditorScene.Layer(
//                transform: drawingTransform,
//                contentSize: layerSize,
//                alpha: 1,
//                content: .drawing(.init(
//                    texture: drawingTexture
//                ))
//            )
//            scene.layers.append(layer)
//        }
        return scene
    }
    
    // MARK: - Interface
    
    func sceneContentSize() -> PixelSize {
        return sceneSize
    }
    
    func onFrame() -> AnimEditorScene? {
        toolState?.onFrame()
        
        let scene = createEditorScene()
        return scene
    }
    
}

// MARK: - Delegates

extension AnimFrameEditor: AnimFrameEditorToolStateDelegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorToolState
    ) -> AnimWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorToolState
    ) -> Size {
        Size(
            Double(drawingSize.width),
            Double(drawingSize.height))
    }
    
    func layerTransform(
        _ s: AnimFrameEditorToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}
