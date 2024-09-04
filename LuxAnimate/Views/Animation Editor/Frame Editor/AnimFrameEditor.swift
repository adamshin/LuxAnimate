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
    ) -> EditorWorkspaceTransform
    
    func onChangeSceneContentSize(
        _ e: AnimFrameEditor)
    
    // TODO: Methods for reporting project edits
    
}

class AnimFrameEditor {
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    
    private let toolState: AnimFrameEditorToolState?
    
    private var projectManifest: Project.Manifest
    private var sceneManifest: Scene.Manifest
    
    weak var delegate: AnimFrameEditorDelegate?
    
    // MARK: - Init
    
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
            toolState = AnimFrameEditorPaintToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize)
            
        case let state as AnimEditorEraseToolState:
            toolState = AnimFrameEditorEraseToolState(
                editorToolState: state,
                drawingCanvasSize: drawingSize)
            
        default:
            toolState = nil
        }
        toolState?.delegate = self
        
        // TODO: Figure out how to update the tool state
        // when the active drawing asset is loaded. The
        // tool should start out inactive, then become
        // active once assets are loaded.
        
        // TODO: Generate frame scene, begin loading assets!
    }
    
    // MARK: - Logic
    
    // MARK: - Interface
    
    func sceneContentSize() -> PixelSize {
        return sceneSize
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        toolState?.onFrame()
        
//        let scene = createEditorScene()
//        return scene
        return nil
    }
    
    func onLoadAsset() {
        // TODO: If all assets are loaded, update the tool
        // state texture. Begin responding to events. Start
        // rendering scene.
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
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorToolState
    ) -> Size {
        Size(drawingSize)
    }
    
    func layerTransform(
        _ s: AnimFrameEditorToolState
    ) -> Matrix3 {
        drawingTransform
    }
    
}
