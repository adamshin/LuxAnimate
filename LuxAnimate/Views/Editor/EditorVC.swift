//
//  EditorVC.swift
//

import UIKit
import PhotosUI

class EditorVC: UIViewController {
    
    private let contentVC = EditorContentVC()
    
    private let projectID: String
//    private let editor: ProjectEditor
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
//        editor = ProjectEditor(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
//        do {
//            try editor.startEditSession()
//        } catch { }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
//    deinit {
//        editor.endEditSession()
//    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        addChild(contentVC, to: view)
    }
    
    // MARK: - UI
    
    private func updateUI() {
//        guard let projectManifest = editor.projectManifest
//        else { return }
//        
//        let projectName = projectManifest.name
//        
//        let drawings = projectManifest
//            .timeline.drawings
//        .map {
//            EditorContentVC.Drawing(id: $0.id)
//        }
//        
//        contentVC.update(projectName: projectName)
//        contentVC.update(drawings: drawings)
    }
    
    // MARK: - Logic
    
    private func createEmptyDrawing() {
//        let imageSize = defaultImageSize
//        let imageData = Self.emptyImageData(
//            imageSize: imageSize)
//        
//        do {
//            try editor.createDrawing(
//                imageData: imageData,
//                imageSize: imageSize)
//            
//            updateUI()
//            
//        } catch { }
    }
    
    private func editDrawing(
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
//        do {
//            try editor.editDrawing(
//                drawingID: drawingID,
//                imageData: imageData,
//                imageSize: imageSize)
//            
//            updateUI()
//            
//        } catch { }
    }
    
//    private static func emptyImageData(
//        imageSize: PixelSize
//    ) -> Data {
//        let byteCount = imageSize.width * imageSize.height * 4
//        return Data(repeating: 0, count: byteCount)
//    }
    
}

// MARK: - Delegates

extension EditorVC: EditorContentVCDelegate {
    
    func onSelectBack(_ vc: EditorContentVC) {
        dismiss(animated: true)
    }
    
    func onSelectBrush(_ vc: EditorContentVC) {
        //
    }
    
    func onSelectClear(_ vc: EditorContentVC) {
        //
    }
    
    func needsDrawCanvas(_ vc: EditorContentVC) {
        //
    }
    
}

extension EditorVC: DrawingEditorVCDelegate {
    
    func onEditDrawing(
        _ vc: DrawingEditorVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
        self.editDrawing(
            drawingID: drawingID,
            imageData: imageData,
            imageSize: imageSize)
    }
    
}
