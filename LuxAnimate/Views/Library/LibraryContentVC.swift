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
    
    @objc private func onSelectCreate() {
        delegate?.onSelectCreateProject()
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
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        delegate?.onSelectProject(id: item.project.id)
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
