//
//  TestFrameEditor.swift
//

import UIKit
import Metal

private let sceneContentSize = PixelSize(1920, 1080)
private let layerContentSize = PixelSize(800, 800)

private let layerTransform =
    Matrix3(translation: Vector(200, 50)) *
    Matrix3(rotation: -.pi/20) *
    Matrix3(shearHorizontal: .pi/10) *
    Matrix3(scale: Vector(1.2, 1))

protocol TestFrameEditorDelegate: AnyObject {
    
    func onChangeSceneContentSize(
        _ e: TestFrameEditor)
    
}

class TestFrameEditor {
    
    weak var delegate: TestFrameEditorDelegate?
    
    // TODO: Logic for loading a single frame and editing content
    
    private let workspaceRenderer = TestEditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    // MARK: - Interface
    
    func getSceneContentSize() -> PixelSize {
        return sceneContentSize
    }
    
    func clearCanvas() {
//        let texture = try! TextureCreator
//            .createEmptyTexture(
//                size: layerContentSize,
//                mipMapped: false)
//
//        brushEngine.setCanvasTexture(texture)
    }
    
    func onFrame(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: TestWorkspaceTransform
    ) {
        // TODO: Update active tool
        
        drawWorkspace(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
    // MARK: - Render
    
    private func drawWorkspace(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: TestWorkspaceTransform
    ) {
        let sceneSize = Size(
            Double(sceneContentSize.width),
            Double(sceneContentSize.height))
        
        let layerSize = Size(
            Double(layerContentSize.width),
            Double(layerContentSize.height))
        
        let scene = TestEditorScene(layers: [
            TestEditorScene.Layer(
                transform: .identity,
                contentSize: sceneSize,
                alpha: 1,
                content: .rect(.init(
                    color: .brushBlue
                ))
            ),
            TestEditorScene.Layer(
                transform: layerTransform,
                contentSize: layerSize,
                alpha: 1,
                content: .rect(.init(
                    color: .white
                ))
            ),
//            TestEditorScene.Layer(
//                transform: layerTransform,
//                contentSize: layerSize,
//                alpha: 1,
//                content: .drawing(.init(
//                    texture: brushEngine.activeCanvasTexture
//                ))
//            ),
        ])
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        workspaceRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            scene: scene)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
