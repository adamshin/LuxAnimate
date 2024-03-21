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
            _ = try libraryManager.createProject()
            reloadData()
            
        } catch { 
            print(error)
        }
    }
    
    func onSelectProject(_ project: LibraryManager.Project) {
        let vc = EditorVC(projectID: project.id)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}
