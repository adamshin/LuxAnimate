//
//  LibraryVC.swift
//

import UIKit

class LibraryVC: UIViewController {
    
    private let contentVC = LibraryContentVC()
    
    private let libraryManager: LibraryManager
    
    // MARK: - Initializer
    
    init() {
        libraryManager = try! LibraryManager()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
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
        let vc = EditorVC(projectURL: project.url)
        present(vc, animated: true)
    }
    
}
