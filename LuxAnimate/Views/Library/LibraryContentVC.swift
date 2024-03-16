//
//  LibraryContentVC.swift
//

import UIKit

protocol LibraryContentVCDelegate: AnyObject {
    func onSelectCreateProject()
    func onSelectProject(_ project: LibraryManager.Project)
}

extension LibraryContentVC {
    
    struct Item {
        var project: LibraryManager.Project
    }
    
}

class LibraryContentVC: UIViewController {
    
    weak var delegate: LibraryContentVCDelegate?
    
    private let tableView = UITableView()
    
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
        view.addSubview(tableView)
        tableView.pinEdges()
        tableView.register(UITableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.title = "Library"
        navigationItem.rightBarButtonItem = createButton
    }
    
    @objc private func onSelectCreate() {
        delegate?.onSelectCreateProject()
    }
    
    // MARK: - Interface
    
    func update(items: [Item]) {
        self.items = items
        tableView.reloadData()
    }
    
}

extension LibraryContentVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        items.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        return tableView.dequeue(UITableViewCell.self) {
            $0.textLabel?.text = item.project.name
        }
    }
    
}

extension LibraryContentVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        delegate?.onSelectProject(item.project)
    }
    
}
