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
        imageWidth: Int,
        imageHeight: Int
    ) throws {
        guard let editSession else { return }
        
        // Resize images
        let previewMediumImageData = try imageResizer.resize2(
            imageData: imageData,
            width: imageWidth,
            height: imageHeight,
            targetWidth: AppConfig.assetPreviewMediumSize,
            targetHeight: AppConfig.assetPreviewMediumSize)
        
        let previewSmallImageData = try imageResizer.resize2(
            imageData: imageData,
            width: imageWidth,
            height: imageHeight,
            targetWidth: AppConfig.assetPreviewSmallSize,
            targetHeight: AppConfig.assetPreviewSmallSize)
        
        // Encode images
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageWidth,
                height: imageHeight),
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
        
        // Apply edit
        let fullAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: fullEncodedData)
        
        let previewMediumAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: previewMediumEncodedData)
        
        let previewSmallAsset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: previewSmallEncodedData)
        
        let drawing = Project.Drawing(
            id: UUID().uuidString,
            frameIndex: 0,
            animationLayerID: "",
            drawingLayerID: "",
            assets: .init(
                full: fullAsset.id,
                previewMedium: previewMediumAsset.id,
                previewSmall: previewSmallAsset.id))
        
        var projectManifest = editSession.currentProjectManifest
        
        projectManifest.timeline.drawings.append(drawing)
        projectManifest.assets.assetIDs.insert(fullAsset.id)
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: [
                fullAsset,
                previewMediumAsset,
                previewSmallAsset,
            ])
    }
    
}
