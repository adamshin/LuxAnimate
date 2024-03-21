//
//  EditorVC.swift
//

import UIKit
import PhotosUI

private let buttonSpacing: CGFloat = 16

class EditorVC: UIViewController {
    
    private let projectID: String
    private let editor: ProjectEditor?
    
    private lazy var backButton = UIBarButtonItem(
        title: "Back", style: .plain,
        target: self, action: #selector(onSelectBack))
    
    private let undoButton = UIBarButtonItem(title: "Undo")
    private let redoButton = UIBarButtonItem(title: "Redo")
    private let addDrawingButton = UIBarButtonItem(title: "Add Drawing")
    
    private let infoLabel = UILabel()
    
    // MARK: - Initializer
    
    init(projectID: String) {
        self.projectID = projectID
        
        editor = try? ProjectEditor(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Project Editor"
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(infoLabel)
        infoLabel.pinCenter()
        infoLabel.numberOfLines = 0
        
        let toolbar = UIToolbar()
        view.addSubview(toolbar)
        toolbar.frame.size = CGSize(width: 1000, height: 44)
        toolbar.pinEdges([.horizontal, .bottom], to: view.safeAreaLayoutGuide)
        
        toolbar.items = [
            undoButton,
            UIBarButtonItem.fixedSpace(buttonSpacing),
            redoButton,
            UIBarButtonItem.fixedSpace(buttonSpacing),
            addDrawingButton,
        ]
        
        undoButton.target = self
        undoButton.action = #selector(onSelectUndo)
        
        redoButton.target = self
        redoButton.action = #selector(onSelectRedo)
        
        addDrawingButton.target = self
        addDrawingButton.action = #selector(onSelectAddDrawing)
    }
    
    // MARK: - UI
    
    private func updateUI() {
        guard let editor else { return }
        
        let projectManifest = editor.currentProjectManifest
        
        infoLabel.text = """
            Name: \(projectManifest.name)
            Created: \(projectManifest.createdAt)
            Drawings: \(projectManifest.drawings.count)
            """
        
        undoButton.isEnabled = editor.isUndoAvailable
        redoButton.isEnabled = editor.isRedoAvailable
    }
    
    // MARK: - Handlers
    
    @objc private func onSelectBack() {
        dismiss(animated: true)
    }
    
    @objc private func onSelectUndo() {
        do {
            try editor?.applyUndo()
        } catch { }
        
        updateUI()
    }
    
    @objc private func onSelectRedo() {
        do {
            try editor?.applyRedo()
        } catch { }
        
        updateUI()
    }
    
    @objc private func onSelectAddDrawing() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    // MARK: - Editing
    
    func addDrawing(pngData: Data) {
        guard let editor else { return }
        
        let newAssetID = UUID().uuidString
        let newAsset = ProjectEditor.NewAsset(
            id: newAssetID,
            data: pngData)
        
        let drawing = ProjectManifest.Drawing(assetID: newAssetID)
        
        var projectManifest = editor.currentProjectManifest
        projectManifest.referencedAssetIDs.append(newAssetID)
        projectManifest.drawings.append(drawing)
        
        do {
            try editor.applyEdit(
                newProjectManifest: projectManifest,
                newAssets: [newAsset])
        } catch {
            print(error)
        }
        
        updateUI()
    }
    
}

// MARK: - Extensions

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
            guard let pngData = image.pngData() else { return }
            
            DispatchQueue.main.async {
                self?.addDrawing(pngData: pngData)
            }
        }
    }
    
}
