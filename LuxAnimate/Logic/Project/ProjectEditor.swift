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
        let mediumImageData = try imageResizer.resize(
            imageData: imageData,
            width: imageSize.width,
            height: imageSize.height,
            targetWidth: AppConfig.assetPreviewMediumSize,
            targetHeight: AppConfig.assetPreviewMediumSize)
        
        let smallImageData = try imageResizer.resize(
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
        
        let mediumEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: mediumImageData,
                width: AppConfig.assetPreviewMediumSize,
                height: AppConfig.assetPreviewMediumSize),
            lossless: false,
            quality: 90,
            effort: 1)
        
        let smallEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: smallImageData,
                width: AppConfig.assetPreviewSmallSize,
                height: AppConfig.assetPreviewSmallSize),
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
