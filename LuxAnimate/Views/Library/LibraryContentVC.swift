//
//  LibraryContentVC.swift
//

import UIKit

private let portraitColumnCount = 3
private let landscapeColumnCount = 5

private let sidePadding: CGFloat = 20
private let topPadding: CGFloat = 40
private let bottomPadding: CGFloat = 40

private let itemHeight: CGFloat = 240

protocol LibraryContentVCDelegate: AnyObject {
    
    func onSelectCreateProject()
    
    func onSelectProject(id: String)
    func onSelectRenameProject(id: String, name: String)
    func onSelectDeleteProject(id: String)
    
}

extension LibraryContentVC {
    
    struct Item {
        var project: LibraryManager.LibraryProject
    }
    
}

class LibraryContentVC: UIViewController {
    
    weak var delegate: LibraryContentVCDelegate?
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout)
    
    private let flowLayout = LayoutInvalidatingFlowLayout()
    
    private let cellRegistration = UICollectionView.CellRegistration<
        LibraryCell, Item
    > { cell, indexPath, item in
        cell.configure(item: item)
    }
    
    private lazy var createButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"), style: .plain,
        target: self, action: #selector(onSelectCreate))
    
    private var items: [Item] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.pinEdges()
        collectionView.backgroundColor = .editorBackground
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.title = "Library"
        navigationItem.rightBarButtonItem = createButton
    }
    
    // MARK: - Handlers
    
    @objc private func onSelectCreate() {
        delegate?.onSelectCreateProject()
    }
    
    private func onSelectRenameItem(_ item: Item) {
        showRenameAlert(
            originalName: item.project.name
        ) { name in
            self.delegate?.onSelectRenameProject(
                id: item.project.id,
                name: name)
        }
    }
    
    private func onSelectDeleteItem(_ item: Item) {
        showDeleteAlert {
            self.delegate?.onSelectDeleteProject(
                id: item.project.id)
        }
    }
    
    // MARK: - Navigation
    
    private func showDeleteAlert(delete: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Delete Project?",
            message: nil,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Cancel", style: .cancel,
            handler: { _ in }))
        
        alert.addAction(UIAlertAction(
            title: "Delete", style: .destructive,
            handler: { _ in delete() }))
        
        present(alert, animated: true)
    }
    
    private func showRenameAlert(
        originalName: String,
        completion: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(
            title: "Rename Project",
            message: nil,
            preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = originalName
        }
        
        alert.addAction(UIAlertAction(
            title: "Cancel", style: .cancel,
            handler: { _ in }))
        
        alert.addAction(UIAlertAction(
            title: "Rename", style: .default,
            handler: { _ in
                let name = alert.textFields?.first?.text ?? ""
                completion(name)
            }))
        
        present(alert, animated: true)
    }
    
    // MARK: - Interface
    
    func update(items: [Item]) {
        self.items = items
        collectionView.reloadData()
    }
    
}

extension LibraryContentVC: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item)
    }
    
}

extension LibraryContentVC: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = items[indexPath.item]
        delegate?.onSelectProject(id: item.project.id)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard let indexPath = indexPaths.first
        else { return nil }
        
        let index = indexPath.item
        let item = items[index]
        
        return UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: [
                UIAction(
                    title: "Rename",
                    image: .init(systemName: "pencil"))
                { _ in
                    self.onSelectRenameItem(item)
                },
                UIAction(
                    title: "Delete",
                    image: .init(systemName: "trash"),
                    attributes: [.destructive])
                { _ in
                    self.onSelectDeleteItem(item)
                },
            ])
        })
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        
        let cell = collectionView.cellForItem(at: indexPath)
        guard let cell = cell as? LibraryCell
        else { return nil }
        
        let preview = UITargetedPreview(view: cell.cardView)
        return preview
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        
        let cell = collectionView.cellForItem(at: indexPath)
        guard let cell = cell as? LibraryCell
        else { return nil }
        
        let preview = UITargetedPreview(view: cell.cardView)
        return preview
    }
    
}

extension LibraryContentVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let bounds = collectionView.bounds
        
        let columnCount = 
            bounds.width < bounds.height ?
            portraitColumnCount : landscapeColumnCount
        
        let availableWidth = bounds.width - sidePadding * 2
        let itemWidth = availableWidth / Double(columnCount)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: topPadding, left: sidePadding,
            bottom: bottomPadding, right: sidePadding)
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
}
