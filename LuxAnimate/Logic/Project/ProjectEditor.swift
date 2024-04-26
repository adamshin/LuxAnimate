//
//  ProjectEditor.swift
//

import Foundation

class ProjectEditor {
    
    private let projectID: String
    
    private var editSession: ProjectEditSession? = nil
    
    private let imageResizer = ImageResizer()
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    func startEditSession() throws {
        editSession = try ProjectEditSession(projectID: projectID)
    }
    
    func endEditSession() {
        editSession = nil
    }
    
    var projectManifest: Project.Manifest? {
        editSession?.currentProjectManifest
    }
    
}

extension ProjectEditor {
    
    func createDrawing(
        size: PixelSize,
        imageData: Data,
        imageSize: PixelSize
    ) throws {
        guard let editSession else { return }
        
        let createdAssets = try createDrawingAssets(
            imageData: imageData,
            imageSize: imageSize)
        
        let drawing = Project.Drawing(
            id: UUID().uuidString,
            frameIndex: 0,
            size: size,
            assetIDs: createdAssets.assetIDs)
        
        var projectManifest = editSession.currentProjectManifest
        
        projectManifest.timeline.drawings.append(drawing)
        
        for assetID in createdAssets.assetIDs.all {
            projectManifest.assetIDs.insert(assetID)
        }
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: createdAssets.newAssets)
    }
    
    func editDrawing(
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) throws {
        guard let editSession else { return }
        
        let createdAssets = try createDrawingAssets(
            imageData: imageData,
            imageSize: imageSize)
        
        var projectManifest = editSession.currentProjectManifest
        
        guard let drawingIndex = projectManifest.timeline.drawings
            .firstIndex(where: { $0.id == drawingID })
        else { return }
        
        let drawing = projectManifest.timeline.drawings[drawingIndex]
        for assetID in drawing.assetIDs.all {
            projectManifest.assetIDs.remove(assetID)
        }
        
        projectManifest.timeline.drawings[drawingIndex]
            .assetIDs = createdAssets.assetIDs
        
        for assetID in createdAssets.assetIDs.all {
            projectManifest.assetIDs.insert(assetID)
        }
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: createdAssets.newAssets)
    }
    
    private struct CreatedDrawingAssets {
        var assetIDs: Project.DrawingAssetIDGroup
        var newAssets: [ProjectEditSession.NewAsset]
    }
    
    private func createDrawingAssets(
        imageData: Data,
        imageSize: PixelSize
    ) throws -> CreatedDrawingAssets {
        
        // Resize images
        let previewMediumImageData = try imageResizer.resize(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            targetWidth: AppConfig.assetPreviewMediumSize,
            targetHeight: AppConfig.assetPreviewMediumSize)
        
        let previewSmallImageData = try imageResizer.resize(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            targetWidth: AppConfig.assetPreviewSmallSize,
            targetHeight: AppConfig.assetPreviewSmallSize)
        
        // Encode images
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageSize.width,
                height: imageSize.height),
            lossless: true,
            quality: 100,
            effort: 1)
        
        let previewMediumEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: previewMediumImageData,
                width: AppConfig.assetPreviewMediumSize,
                height: AppConfig.assetPreviewMediumSize),
            lossless: false,
            quality: 90,
            effort: 1)
        
        let previewSmallEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: previewSmallImageData,
                width: AppConfig.assetPreviewSmallSize,
                height: AppConfig.assetPreviewSmallSize),
            lossless: false,
            quality: 90,
            effort: 1)
        
        // Create assets
        let fullAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: fullEncodedData)
        
        let previewMediumAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: previewMediumEncodedData)
        
        let previewSmallAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: previewSmallEncodedData)
        
        return CreatedDrawingAssets(
            assetIDs: Project.DrawingAssetIDGroup(
                full: fullAsset.id,
                previewMedium: previewMediumAsset.id,
                previewSmall: previewSmallAsset.id),
            newAssets: [
                fullAsset,
                previewMediumAsset,
                previewSmallAsset,
            ])
    }
    
}
