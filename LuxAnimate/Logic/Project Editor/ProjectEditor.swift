//
//  ProjectEditor.swift
//

import Foundation
import Metal

protocol ProjectEditorDelegate: AnyObject {
    
    func onEditProject(
        _ editor: ProjectEditor,
        editContext: Any?)
    
}

class ProjectEditor {
    
    weak var delegate: ProjectEditorDelegate?
    
    private let projectID: String
    private let editSession: ProjectEditSession
    
    private let queue = ProjectEditorWorkQueue()
    
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
        
        queue.enqueueSync {
            do {
                let createdAssets = try self.createDrawingAssets(
                    texture: texture)
                
                let drawing = Project.Drawing(
                    id: UUID().uuidString,
                    frameIndex: frameIndex,
                    assetIDs: createdAssets.assetIDs)
                
                var projectManifest = self.editSession.currentProjectManifest
                
                guard !projectManifest.content.animationLayer.drawings
                    .contains(where: { $0.frameIndex == frameIndex })
                else { return }
                
                projectManifest.content.animationLayer.drawings
                    .append(drawing)
                
                for assetID in createdAssets.assetIDs.all {
                    projectManifest.assetIDs.insert(assetID)
                }
                
                try self.editSession.applyEdit(
                    newProjectManifest: projectManifest,
                    newAssets: createdAssets.newAssets)
                
            } catch { }
        }
        
        delegate?.onEditProject(self, editContext: nil)
    }
    
    func createEmptyDrawing(
        frameIndex: Int
    ) throws {
        
        let projectManifest = editSession.currentProjectManifest
        
        let imageSize = projectManifest.content
            .animationLayer.size
        
        let texture = try TextureCreator.createEmptyTexture(
            size: imageSize,
            mipMapped: false)
        
        try createDrawing(
            frameIndex: frameIndex,
            texture: texture)
    }
    
    // MARK: - Edit Drawing
    
    func editDrawing(
        drawingID: String,
        drawingTexture: MTLTexture,
        editContext: Any?
    ) throws {
        
        let texture = try TextureCopier.copy(drawingTexture)
        
        queue.enqueue {
            do {
                let createdAssets = try self.createDrawingAssets(
                    texture: texture)
                
                var projectManifest = self.editSession.currentProjectManifest
                
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
                
                try self.editSession.applyEdit(
                    newProjectManifest: projectManifest,
                    newAssets: createdAssets.newAssets)
                
                DispatchQueue.main.async {
                    self.delegate?.onEditProject(
                        self,
                        editContext: editContext)
                }
                
            } catch { }
        }
    }
    
    // MARK: - Delete Drawing
    
    func deleteDrawing(at frameIndex: Int) throws {
        queue.enqueueSync {
            do {
                var projectManifest = self.editSession.currentProjectManifest
                
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
                
                try self.editSession.applyEdit(
                    newProjectManifest: projectManifest,
                    newAssets: [])
                
            } catch { }
        }
        
        delegate?.onEditProject(self, editContext: nil)
    }
    
    // MARK: - Spacing
    
    func insertSpacing(at frameIndex: Int) throws {
        queue.enqueueSync {
            do {
                var projectManifest = self.editSession.currentProjectManifest
                var drawings = projectManifest.content.animationLayer.drawings
                
                for index in drawings.indices {
                    if drawings[index].frameIndex > frameIndex {
                        drawings[index].frameIndex += 1
                    }
                }
                projectManifest.content.animationLayer.drawings = drawings
                
                try self.editSession.applyEdit(
                    newProjectManifest: projectManifest,
                    newAssets: [])
                
            } catch { }
        }
        
        delegate?.onEditProject(self, editContext: nil)
    }
    
    func removeSpacing(at frameIndex: Int) throws {
        queue.enqueueSync {
            do {
                var projectManifest = self.editSession.currentProjectManifest
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
                
                try self.editSession.applyEdit(
                    newProjectManifest: projectManifest,
                    newAssets: [])
                
            } catch { }
        }
        
        delegate?.onEditProject(self, editContext: nil)
    }
    
    // MARK: - Undo / Redo
    
    func applyUndo() throws {
        queue.enqueueSync {
            do {
                try self.editSession.applyUndo()
            } catch { }
        }
        delegate?.onEditProject(self, editContext: nil)
    }
    
    func applyRedo() throws {
        queue.enqueueSync {
            do {
                try self.editSession.applyRedo()
            } catch { }
        }
        delegate?.onEditProject(self, editContext: nil)
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
            targetSize: mediumImageSize)
        
        let smallImageData = try imageResizer.resize(
            imageTexture: texture,
            targetSize: smallImageSize)
        
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
