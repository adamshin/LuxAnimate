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
    private let deleteDrawingButton = UIBarButtonItem(title: "Delete Drawing")
    
    private let infoLabel = UILabel()
    private var imageViews: [UIImageView] = []
    
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
        infoLabel.pin(.centerX)
        infoLabel.pinEdges(.top, to: view.safeAreaLayoutGuide, padding: 40)
        infoLabel.numberOfLines = 0
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        view.addSubview(stack)
        stack.pinCenter()
        
        for _ in 0..<15 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.pinSize(to: 60)
            
            imageViews.append(imageView)
            stack.addArrangedSubview(imageView)
        }
        
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
            UIBarButtonItem.fixedSpace(buttonSpacing),
            deleteDrawingButton,
        ]
        
        undoButton.target = self
        undoButton.action = #selector(onSelectUndo)
        
        redoButton.target = self
        redoButton.action = #selector(onSelectRedo)
        
        addDrawingButton.target = self
        addDrawingButton.action = #selector(onSelectAddDrawing)
        
        deleteDrawingButton.target = self
        deleteDrawingButton.action = #selector(onSelectDeleteDrawing)
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
        
        imageViews.forEach { $0.image = nil }
        
        for (drawing, imageView) in zip(projectManifest.drawings, imageViews) {
            let url = FileUrlHelper().projectAssetURL(
                projectID: projectID,
                assetID: drawing.assetID)
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data ?? Data())
            imageView.image = image
        }
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
    
    @objc private func onSelectDeleteDrawing() {
        deleteLastDrawing()
    }
    
    // MARK: - Editing
    
    private func addDrawing(pngData: Data) {
        guard let editor else { return }
        
        let newAssetID = UUID().uuidString
        let newAsset = ProjectEditor.NewAsset(
            id: newAssetID,
            data: pngData)
        
        let drawing = ProjectManifest.Drawing(assetID: newAssetID)
        
        var projectManifest = editor.currentProjectManifest
        projectManifest.referencedAssetIDs.insert(newAssetID)
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
    
    private func deleteLastDrawing() {
        guard let editor else { return }
        
        var projectManifest = editor.currentProjectManifest
        
        guard let lastDrawing = projectManifest.drawings.last
        else { return }
        
        projectManifest.drawings.removeLast()
        projectManifest.referencedAssetIDs.remove(lastDrawing.assetID)
        
        do {
            try editor.applyEdit(
                newProjectManifest: projectManifest,
                newAssets: [])
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
