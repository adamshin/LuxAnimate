//
//  ProjectEditorContentVC.swift
//

import UIKit

@MainActor
protocol ProjectEditorContentVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: ProjectEditorContentVC)
    
    func onSelectAddScene(_ vc: ProjectEditorContentVC)
    func onSelectRemoveScene(_ vc: ProjectEditorContentVC)
    func onSelectUndo(_ vc: ProjectEditorContentVC)
    func onSelectRedo(_ vc: ProjectEditorContentVC)
    
    func onSelectScene(
        _ vc: ProjectEditorContentVC,
        sceneID: String)
    
}

class ProjectEditorContentVC: UIViewController {
    
    weak var delegate: ProjectEditorContentVCDelegate?
    
    // TODO: Make this non-optional, with a placeholder empty value?
    private var model: ProjectEditorModel?
    
    private lazy var backButton = UIBarButtonItem(
        title: "Back", style: .done,
        target: self, action: #selector(onSelectBack))
    
    private lazy var addSceneButton = UIBarButtonItem(
        title: "Add Scene", style: .plain,
        target: self, action: #selector(onSelectAddScene))
    private lazy var removeSceneButton = UIBarButtonItem(
        title: "Remove Scene", style: .plain,
        target: self, action: #selector(onSelectRemoveScene))
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
            removeSceneButton,
            UIBarButtonItem.fixedSpace(20),
            addSceneButton,
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
    @objc private func onSelectAddScene() {
        delegate?.onSelectAddScene(self)
    }
    @objc private func onSelectRemoveScene() {
        delegate?.onSelectRemoveScene(self)
    }
    @objc private func onSelectUndo() {
        delegate?.onSelectUndo(self)
    }
    @objc private func onSelectRedo() {
        delegate?.onSelectRedo(self)
    }
    
    func update(model: ProjectEditorModel) {
        self.model = model
        
        navigationItem.title = model.projectManifest.name
        
        updateButtons()
        tableView.reloadData()
    }
    
    private func updateButtons() {
        guard let model else { return }
        
        removeSceneButton.isEnabled =
            model.projectManifest.content.sceneRefs.count > 0
        
        undoButton.isEnabled = model.availableUndoCount > 0
        redoButton.isEnabled = model.availableRedoCount > 0
    }
    
}

// MARK: - Table View

extension ProjectEditorContentVC: UITableViewDataSource {
    
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
            model?.projectManifest.content.sceneRefs.count ?? 0
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
        
        guard let model else { return cell }
        
        switch indexPath.section {
        case 0:
            cell.accessoryType = .none
            
            switch indexPath.row {
            case 0:
                let viewportSize = model.projectManifest
                    .content.metadata.viewportSize
                let framesPerSecond = model.projectManifest
                    .content.metadata.framesPerSecond
                
                cell.textLabel?.text = """
                    \(viewportSize.width) × \(viewportSize.height)\
                    \u{2002}\u{2022}\u{2002}\
                    \(framesPerSecond) fps
                    """
                
            case 1:
                let sceneCount = model.projectManifest
                    .content.sceneRefs.count
                let assetCount = model.projectManifest
                    .assetIDs.count
                
                let sceneText = "\(sceneCount) \(sceneCount == 1 ? "scene" : "scenes")"
                
                let assetText = "\(assetCount) \(assetCount == 1 ? "asset" : "assets")"
                
                cell.textLabel?.text = "\(sceneText), \(assetText)"
                
            default:
                break
            }
            
        case 1:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Scene \(indexPath.row + 1)"
            
        default:
            break
        }
        
        return cell
    }
    
}

extension ProjectEditorContentVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            guard let model else { return }
            let sceneRef = model.projectManifest.content.sceneRefs[indexPath.row]
            delegate?.onSelectScene(self, sceneID: sceneRef.id)
        }
    }
    
}
