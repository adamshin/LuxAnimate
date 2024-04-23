//
//  EditorContentVC.swift
//

import UIKit

protocol EditorContentVCDelegate: AnyObject {
    func onSelectBack()
    func onSelectCreateDrawing()
    func onSelectDrawing(id: String)
}

extension EditorContentVC {
    
    struct Drawing {
        var id: String
    }
    
}

class EditorContentVC: UIViewController {
    
    weak var delegate: EditorContentVCDelegate?
    
    private let tableView = UITableView()
    
    private lazy var backButton = UIBarButtonItem(
        title: "Back", style: .plain,
        target: self, action: #selector(onSelectBack))
    
    private lazy var createDrawingButton = UIBarButtonItem(
        title: "Add Drawing", style: .plain,
        target: self, action: #selector(onSelectCreateDrawing))
    
    private var drawings: [Drawing] = []
    
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
        
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = createDrawingButton
    }
    
    @objc private func onSelectBack() {
        delegate?.onSelectBack()
    }
    
    @objc private func onSelectCreateDrawing() {
        delegate?.onSelectCreateDrawing()
    }
    
    // MARK: - Interface
    
    func update(projectName: String) {
        navigationItem.title = projectName
    }
    
    func update(drawings: [Drawing]) {
        self.drawings = drawings
        tableView.reloadData()
    }
    
}

extension EditorContentVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        drawings.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        return tableView.dequeue(UITableViewCell.self) {
            $0.textLabel?.text = "Drawing \(indexPath.row + 1)"
        }
    }
    
}

extension EditorContentVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let drawing = drawings[indexPath.row]
        delegate?.onSelectDrawing(id: drawing.id)
    }
    
}

