//
//  ProjectEditor.swift
//

import Foundation

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
        imageData: Data,
        imageSize: PixelSize
    ) throws {
        
        let createdAssets = try createDrawingAssets(
            imageData: imageData,
            imageSize: imageSize)
        
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
        
        try createDrawing(
            frameIndex: frameIndex,
            imageData: imageData,
            imageSize: imageSize)
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
        imageData: Data,
        imageSize: PixelSize
    ) throws {
        
        let createdAssets = try createDrawingAssets(
            imageData: imageData,
            imageSize: imageSize)
        
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
    
    // MARK: - Assets
    
    private struct CreatedDrawingAssets {
        var assetIDs: Project.DrawingAssetIDGroup
        var newAssets: [ProjectEditSession.NewAsset]
    }
    
    private func createDrawingAssets(
        imageData: Data,
        imageSize: PixelSize
    ) throws -> CreatedDrawingAssets {
        
        let imageAspectRatio =
            Double(imageSize.width) /
            Double(imageSize.height)
        
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
        
        // Resize images
        let mediumImageData = try imageResizer.resize(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            targetWidth: mediumImageSize.width,
            targetHeight: mediumImageSize.height)
        
        let smallImageData = try imageResizer.resize(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            targetWidth: smallImageSize.width,
            targetHeight: smallImageSize.height)
        
        // Encode images
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageSize.width,
                height: imageSize.height),
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

private extension PixelSize {
    
    init(filling containerSize: PixelSize, aspectRatio: Double) {
        let containerAspectRatio =
            Double(containerSize.width) /
            Double(containerSize.height)
        
        if aspectRatio > containerAspectRatio {
            self = PixelSize(
                width: Int(Double(containerSize.height) * aspectRatio),
                height: containerSize.height)
        } else {
            self = PixelSize(
                width: containerSize.width,
                height: Int(Double(containerSize.width) / aspectRatio))
        }
    }

    init(fitting containerSize: PixelSize, aspectRatio: Double) {
        let containerAspectRatio =
            Double(containerSize.width) /
            Double(containerSize.height)
        
        if aspectRatio > containerAspectRatio {
            self = PixelSize(
                width: containerSize.width,
                height: Int(Double(containerSize.width) / aspectRatio))
        } else {
            self = PixelSize(
                width: Int(Double(containerSize.height) * aspectRatio),
                height: containerSize.height)
        }
    }
    
}
