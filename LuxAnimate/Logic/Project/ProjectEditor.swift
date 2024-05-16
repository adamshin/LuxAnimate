//
//  ProjectEditor.swift
//

import Foundation
import Metal

protocol ProjectEditorDelegate: AnyObject {
    
    func onEditProject(_ editor: ProjectEditor)
    
}

class ProjectEditor {
    
    weak var delegate: ProjectEditorDelegate?
    
    private let projectID: String
    private let editSession: ProjectEditSession
    
    private let imageResizer = ImageResizer()
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editSession = try ProjectEditSession(
            projectID: projectID)
    }
    
    var currentProjectManifest: Project.Manifest {
        editSession.currentProjectManifest
    }
    
}

extension ProjectEditor {
    
    // MARK: - Create Drawing
    
    func createDrawing(
        frameIndex: Int,
        texture: MTLTexture
    ) throws {
        
        let createdAssets = try createDrawingAssets(
            texture: texture)
        
        let drawing = Project.Drawing(
            id: UUID().uuidString,
            frameIndex: frameIndex,
            assetIDs: createdAssets.assetIDs)
        
        var projectManifest = editSession.currentProjectManifest
        
        guard !projectManifest.content.animationLayer.drawings
            .contains(where: { $0.frameIndex == frameIndex })
        else { return }
        
        projectManifest.content.animationLayer.drawings
            .append(drawing)
        
        for assetID in createdAssets.assetIDs.all {
            projectManifest.assetIDs.insert(assetID)
        }
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: createdAssets.newAssets)
        
        delegate?.onEditProject(self)
    }
    
    func createEmptyDrawing(
        frameIndex: Int
    ) throws {
        
        let projectManifest = editSession.currentProjectManifest
        
        let imageSize = projectManifest.content.animationLayer.size
        let imageData = Self.emptyImageData(size: imageSize)
        
        let texture = try TextureCreator.createTexture(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            mipMapped: false)
        
        try createDrawing(
            frameIndex: frameIndex,
            texture: texture)
    }
    
    private static func emptyImageData(
        size: PixelSize
    ) -> Data {
        let byteCount = size.width * size.height * 4
        return Data(repeating: 0, count: byteCount)
    }
    
    // MARK: - Edit Drawing
    
    func editDrawing(
        drawingID: String,
        texture: MTLTexture
    ) throws {
        
        let createdAssets = try createDrawingAssets(
            texture: texture)
        
        var projectManifest = editSession.currentProjectManifest
        
        let drawings = projectManifest.content.animationLayer.drawings
        
        guard let drawingIndex = drawings
            .firstIndex(where: { $0.id == drawingID })
        else { return }
        
        let drawing = drawings[drawingIndex]
        
        for assetID in drawing.assetIDs.all {
            projectManifest.assetIDs.remove(assetID)
        }
        
        projectManifest.content.animationLayer.drawings[drawingIndex]
            .assetIDs = createdAssets.assetIDs
        
        for assetID in createdAssets.assetIDs.all {
            projectManifest.assetIDs.insert(assetID)
        }
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: createdAssets.newAssets)
        
        delegate?.onEditProject(self)
    }
    
    // MARK: - Delete Drawing
    
    func deleteDrawing(at frameIndex: Int) throws {
        var projectManifest = editSession.currentProjectManifest
        
        var filteredDrawings: [Project.Drawing] = []
        
        for drawing in projectManifest.content.animationLayer.drawings {
            if drawing.frameIndex == frameIndex {
                for assetID in drawing.assetIDs.all {
                    projectManifest.assetIDs.remove(assetID)
                }
                
            } else {
                filteredDrawings.append(drawing)
            }
        }
        
        projectManifest.content.animationLayer.drawings = filteredDrawings
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: [])
        
        delegate?.onEditProject(self)
    }
    
    // MARK: - Spacing
    
    func insertSpacing(at frameIndex: Int) throws {
        var projectManifest = editSession.currentProjectManifest
        var drawings = projectManifest.content.animationLayer.drawings
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndex {
                drawings[index].frameIndex += 1
            }
        }
        projectManifest.content.animationLayer.drawings = drawings
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: [])
        
        delegate?.onEditProject(self)
    }
    
    func removeSpacing(at frameIndex: Int) throws {
        var projectManifest = editSession.currentProjectManifest
        var drawings = projectManifest.content.animationLayer.drawings
        
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
        projectManifest.content.animationLayer.drawings = drawings
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: [])
        
        delegate?.onEditProject(self)
    }
    
    // MARK: - Undo / Redo
    
    func applyUndo() throws {
        try editSession.applyUndo()
        delegate?.onEditProject(self)
    }
    
    func applyRedo() throws {
        try editSession.applyRedo()
        delegate?.onEditProject(self)
    }
    
    // MARK: - Assets
    
    private struct CreatedDrawingAssets {
        var assetIDs: Project.DrawingAssetIDGroup
        var newAssets: [ProjectEditSession.NewAsset]
    }
    
    private func createDrawingAssets(
        texture: MTLTexture
    ) throws -> CreatedDrawingAssets {
        
        let imageWidth = texture.width
        let imageHeight = texture.height
        
        let imageAspectRatio =
            Double(imageWidth) /
            Double(imageHeight)
        
        // Read full data
        let imageData = try TextureDataReader.read(texture)
        
        // Resize images
        let mediumImageSize = PixelSize(
            fitting: PixelSize(
                width: AppConfig.assetPreviewMediumSize,
                height: AppConfig.assetPreviewMediumSize),
            aspectRatio: imageAspectRatio)
        
        let smallImageSize = PixelSize(
            fitting: PixelSize(
                width: AppConfig.assetPreviewSmallSize,
                height: AppConfig.assetPreviewSmallSize),
            aspectRatio: imageAspectRatio)
        
        let mediumImageData = try imageResizer.resize(
            imageTexture: texture,
            targetWidth: mediumImageSize.width,
            targetHeight: mediumImageSize.height)
        
        let smallImageData = try imageResizer.resize(
            imageTexture: texture,
            targetWidth: smallImageSize.width,
            targetHeight: smallImageSize.height)
        
        // Encode images
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageWidth,
                height: imageHeight),
            lossless: true,
            quality: 100,
            effort: 1)
        
        let mediumEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: mediumImageData,
                width: mediumImageSize.width,
                height: mediumImageSize.height),
            lossless: false,
            quality: 90,
            effort: 1)
        
        let smallEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: smallImageData,
                width: smallImageSize.width,
                height: smallImageSize.height),
            lossless: false,
            quality: 90,
            effort: 1)
        
        // Create assets
        let fullAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: fullEncodedData)
        
        let mediumAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: mediumEncodedData)
        
        let smallAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: smallEncodedData)
        
        return CreatedDrawingAssets(
            assetIDs: Project.DrawingAssetIDGroup(
                full: fullAsset.id,
                medium: mediumAsset.id,
                small: smallAsset.id),
            newAssets: [
                fullAsset,
                mediumAsset,
                smallAsset,
            ])
    }
    
}
