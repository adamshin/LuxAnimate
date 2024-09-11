//
//  SceneEditorContentVC.swift
//

import UIKit

@MainActor
protocol SceneEditorContentVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: SceneEditorContentVC)
    
    func onSelectAddLayer(_ vc: SceneEditorContentVC, drawingCount: Int)
    func onSelectRemoveLayer(_ vc: SceneEditorContentVC)
    func onSelectUndo(_ vc: SceneEditorContentVC)
    func onSelectRedo(_ vc: SceneEditorContentVC)
    
    func onSelectLayer(
        _ vc: SceneEditorContentVC,
        layerID: String)
    
}

class SceneEditorContentVC: UIViewController {
    
    weak var delegate: SceneEditorContentVCDelegate?
    
    private var sceneRef: Project.SceneRef?
    private var sceneManifest: Scene.Manifest?
    
    private var availableUndoCount = 0
    private var availableRedoCount = 0
    
    private lazy var backButton = UIBarButtonItem(
        title: "Back", style: .done,
        target: self, action: #selector(onSelectBack))
    
    private lazy var addLayerButton = UIBarButtonItem(
        title: "Add Layer", style: .plain,
        target: self, action: #selector(onSelectAddLayer))
    private lazy var addLayer10DrawingsButton = UIBarButtonItem(
        title: "Add Layer (10 drawings)", style: .plain,
        target: self, action: #selector(onSelectAddLayer10Drawings))
    private lazy var removeLayerButton = UIBarButtonItem(
        title: "Remove Layer", style: .plain,
        target: self, action: #selector(onSelectRemoveLayer))
    private lazy var undoButton = UIBarButtonItem(
        title: "Undo", style: .plain,
        target: self, action: #selector(onSelectUndo))
    private lazy var redoButton = UIBarButtonItem(
        title: "Redo", style: .plain,
        target: self, action: #selector(onSelectRedo))
    
    private let tableView = UITableView(
        frame: .zero,
        style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [
            redoButton,
            UIBarButtonItem.fixedSpace(20),
            undoButton,
            UIBarButtonItem.fixedSpace(20),
            removeLayerButton,
            UIBarButtonItem.fixedSpace(20),
            addLayerButton,
            UIBarButtonItem.fixedSpace(20),
            addLayer10DrawingsButton,
        ]
        
        view.addSubview(tableView)
        tableView.pinEdges()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self)
    }
    
    @objc private func onSelectBack() {
        delegate?.onSelectBack(self)
    }
    @objc private func onSelectAddLayer() {
        delegate?.onSelectAddLayer(self, drawingCount: 1)
    }
    @objc private func onSelectAddLayer10Drawings() {
        delegate?.onSelectAddLayer(self, drawingCount: 10)
    }
    @objc private func onSelectRemoveLayer() {
        delegate?.onSelectRemoveLayer(self)
    }
    @objc private func onSelectUndo() {
        delegate?.onSelectUndo(self)
    }
    @objc private func onSelectRedo() {
        delegate?.onSelectRedo(self)
    }
    
    func update(
        projectEditManagerState: ProjectEditManager.State,
        sceneRef: Project.SceneRef,
        sceneManifest: Scene.Manifest
    ) {
        self.sceneRef = sceneRef
        self.sceneManifest = sceneManifest
        self.availableUndoCount = projectEditManagerState.availableUndoCount
        self.availableRedoCount = projectEditManagerState.availableRedoCount
        
        updateButtons()
        tableView.reloadData()
    }
    
    private func updateButtons() {
        guard let sceneManifest else { return }
        
        removeLayerButton.isEnabled =
            sceneManifest.layers.count > 0
        
        undoButton.isEnabled = availableUndoCount > 0
        redoButton.isEnabled = availableRedoCount > 0
    }
    
}

// MARK: - Table View

extension SceneEditorContentVC: UITableViewDataSource {
    
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        2
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            2
        case 1:
            sceneManifest?.layers.count ?? 0
        default:
            0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeue(
            UITableViewCell.self,
            for: indexPath)
        
        guard
            let sceneRef,
            let sceneManifest
        else { return cell }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Scene ID: \(sceneRef.id)"
            case 1:
                cell.textLabel?.text = "Scene Name: \(sceneRef.name)"
            default:
                break
            }
        case 1:
            let layer = sceneManifest.layers[indexPath.row]
            cell.textLabel?.text = "Layer ID: \(layer.id)"
        default:
            break
        }
        
        return cell
    }
    
}

extension SceneEditorContentVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            guard let sceneManifest else { return }
            let layer = sceneManifest.layers[indexPath.row]
            delegate?.onSelectLayer(self, layerID: layer.id)
        }
    }
    
}
