//
//  EditorVC.swift
//

import UIKit
import PhotosUI

class EditorVC: UIViewController {
    
    private let contentVC = EditorContentVC()
    
    private let projectID: String
    private let editor: ProjectEditor
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        editor = ProjectEditor(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        do {
            try editor.startEditSession()
        } catch { }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        editor.endEditSession()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }
    
    // MARK: - UI
    
    private func updateUI() {
        guard let projectManifest = editor.projectManifest
        else { return }
        
        let projectName = projectManifest.name
        
        let drawings = projectManifest
            .timeline.drawings
        .map {
            EditorContentVC.Drawing(id: $0.id)
        }
        
        contentVC.update(projectName: projectName)
        contentVC.update(drawings: drawings)
    }
    
    // MARK: - Logic
    
    private func createDrawing(imageData: Data) {
        do {
            print("Creating drawing")
            try editor.createDrawing(imageData: imageData)
            print("Done creating drawing")
            
            updateUI()
            
        } catch { }
    }
    
}

// MARK: - Delegates

extension EditorVC: EditorContentVCDelegate {
    
    func onSelectBack() {
        dismiss(animated: true)
    }
    
    func onSelectCreateDrawing() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    func onSelectDrawing(id: String) {
        guard let projectManifest = editor.projectManifest
        else { return }
        
        guard let drawing = projectManifest.timeline.drawings
            .first(where: { $0.id == id })
        else { return }
        
        let vc = EditorDrawingVC(
            projectManifest: projectManifest,
            drawing: drawing,
            drawingSize: Size(500, 500))
        
        present(vc, animated: true)
    }
    
}

extension EditorVC: PHPickerViewControllerDelegate {
    
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self)
        { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            
            print("Extracting image data")
            guard let extractedData = try?
                UIImageDataExtractor.imageData(from: image)
            else { return }
            
            print("Encoding JXL image")
            guard let imageData = try? JXLEncoder.encode(
                input: .init(
                    data: extractedData.data,
                    width: extractedData.width,
                    height: extractedData.height),
                lossless: true,
                quality: 100,
                effort: 1)
            else { return }
            print("Done encoding")
            
            DispatchQueue.main.async {
                self?.createDrawing(imageData: imageData)
            }
        }
    }
    
}
