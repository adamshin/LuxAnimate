//
//  LibraryVC.swift
//

import UIKit

class LibraryVC: UIViewController {
    
    private let contentVC = LibraryContentVC()
    
    private let libraryManager = LibraryManager()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }
    
    // MARK: - Data
    
    private func reloadData() {
        do {
            let projects = try libraryManager.getProjects()
            let items = projects.map {
                LibraryContentVC.Item(project: $0)
            }
            contentVC.update(items: items)
            
        } catch { }
    }
    
}

// MARK: - Delegates

extension LibraryVC: LibraryContentVCDelegate {
    
    func onSelectCreateProject() {
        do {
            _ = try libraryManager.createProject(name: "New Project")
            reloadData()
            
        } catch { }
    }
    
    func onSelectProject(id: String) {
        do {
            let vc = try EditorVC(projectID: id)
            present(vc, animated: true)
            
        } catch { }
    }
    
    func onSelectRenameProject(id: String, name: String) {
        do {
            _ = try libraryManager.renameProject(projectID: id, name: name)
            reloadData()
            
        } catch { }
    }
    
    func onSelectDeleteProject(id: String) {
        do {
            _ = try libraryManager.deleteProject(projectID: id)
            reloadData()
            
        } catch { }
    }
    
}
