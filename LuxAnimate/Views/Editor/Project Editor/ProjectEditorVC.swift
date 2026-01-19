//
//  ProjectEditorVC.swift
//

import UIKit
import Color

class ProjectEditorVC: UIViewController {

    private let contentVC = ProjectEditorContentVC()
    private weak var animEditorVC: AnimEditorVC?

    private let projectID: String

    private let editManager: ProjectAsyncEditManager

    // MARK: - Init

    init(projectID: String) throws {
        self.projectID = projectID

        editManager = try ProjectAsyncEditManager(
            projectID: projectID)

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen

        editManager.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupInitialState()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Setup

    private func setupUI() {
        contentVC.delegate = self

        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }

    private func setupInitialState() {
        let model = modelFromEditManager()
        update(model: model)
    }

    // MARK: - Model

    private func modelFromEditManager()
    -> ProjectEditorModel {

        ProjectEditorModel(
            projectManifest: editManager.projectManifest,
            availableUndoCount: editManager.availableUndoCount,
            availableRedoCount: editManager.availableRedoCount)
    }

    private func animEditorInputModel() -> AnimEditorVC.InputModel {
        AnimEditorVC.InputModel(
            projectManifest: editManager.projectManifest,
            availableUndoCount: editManager.availableUndoCount,
            availableRedoCount: editManager.availableRedoCount)
    }

    // MARK: - Logic

    private func update(model: ProjectEditorModel) {
        contentVC.update(model: model)
        animEditorVC?.update(inputModel: animEditorInputModel())
    }

    // MARK: - Editing

    private func addLayer() {
        let projectManifest = editManager.projectManifest

        let edit = ProjectEditBuilder.createLayer(
            projectManifest: projectManifest)

        editManager.applyEdit(edit: edit)
    }

    private func removeLastLayer() {
        let projectManifest = editManager.projectManifest

        guard let lastLayer = projectManifest
            .content.layers.last
        else { return }

        let edit = try! ProjectEditBuilder.deleteLayer(
            projectManifest: projectManifest,
            layerID: lastLayer.id)

        editManager.applyEdit(edit: edit)
    }

    // MARK: - Navigation

    private func showAnimationEditor(layerID: String) {
        do {
            let inputModel = animEditorInputModel()

            let vc = try AnimEditorVC(
                projectID: projectID,
                layerID: layerID,
                inputModel: inputModel,
                focusedFrameIndex: 0)

            vc.delegate = self
            animEditorVC = vc

            present(vc, animated: true)

        } catch { }
    }

}

// MARK: - Delegates

extension ProjectEditorVC: ProjectEditorContentVCDelegate {

    func onSelectBack(_ vc: ProjectEditorContentVC) {
        dismiss(animated: true)
    }

    func onSelectAddLayer(_ vc: ProjectEditorContentVC) {
        addLayer()
    }

    func onSelectRemoveLayer(_ vc: ProjectEditorContentVC) {
        removeLastLayer()
    }

    func onSelectUndo(_ vc: ProjectEditorContentVC) {
        editManager.applyUndo()
    }

    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        editManager.applyRedo()
    }

    func onSelectLayer(
        _ vc: ProjectEditorContentVC,
        layerID: String
    ) {
        showAnimationEditor(layerID: layerID)
    }

}

extension ProjectEditorVC: AnimEditorVC.Delegate {

    func onRequestUndo(_ vc: AnimEditorVC) {
        editManager.applyUndo()
    }

    func onRequestRedo(_ vc: AnimEditorVC) {
        editManager.applyRedo()
    }

    func onRequestEdit(
        _ vc: AnimEditorVC,
        layer: Project.Layer,
        layerContentEdit: AnimationLayerContentEditBuilder.Edit
    ) {
        let projectManifest = editManager.projectManifest

        do {
            let layerEdit = try AnimationLayerContentEditBuilder
                .applyAnimationLayerContentEdit(
                    projectManifest: projectManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)

            let edit = try ProjectEditBuilder.applyLayerEdit(
                projectManifest: projectManifest,
                layerEdit: layerEdit)

            editManager.applyEdit(edit: edit)

        } catch { }
    }

    func pendingEditAsset(
        _ vc: AnimEditorVC,
        assetID: String
    ) -> ProjectEditManager.NewAsset? {

        editManager.pendingEditAsset(
            assetID: assetID)
    }

}

extension ProjectEditorVC: ProjectAsyncEditManager.Delegate {

    func onUpdateState(
        _ m: ProjectAsyncEditManager
    ) {
        let model = modelFromEditManager()
        update(model: model)
    }

    func onEditError(
        _ m: ProjectAsyncEditManager,
        error: Error
    ) { }

}
