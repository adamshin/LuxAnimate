//
//  ProjectEditor.swift
//

import Foundation

class ProjectEditor {
    
    private let projectID: String
    
    private var editSession: ProjectEditSession? = nil
    
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
    
    func createDrawing(imageData: Data) throws {
        guard let editSession else { return }
        
        // TODO: generate preview image sizes!
        
        let asset = ProjectEditSession.NewAsset(
            id: UUID().uuidString,
            data: imageData)
        
        let drawing = Project.Drawing(
            id: UUID().uuidString,
            frameIndex: 0,
            animationLayerID: "",
            drawingLayerID: "",
            assets: .init(
                full: asset.id,
                previewMedium: "",
                previewSmall: ""))
        
        var projectManifest = editSession.currentProjectManifest
        
        projectManifest.timeline.drawings.append(drawing)
        projectManifest.assets.assetIDs.insert(asset.id)
        
        try editSession.applyEdit(
            newProjectManifest: projectManifest,
            newAssets: [asset])
    }
    
}
