//
//  EditorVC.swift
//

import UIKit

class EditorVC: UIViewController {
    
    private let projectURL: URL
    
    private var projectManifest: ProjectManifest?
    
    private let reader = EditorProjectReader()
    
    private let infoLabel = UILabel()
    
    // MARK: - Initializer
    
    init(projectURL: URL) {
        self.projectURL = projectURL
        
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
        view.backgroundColor = .systemBackground
        
        view.addSubview(infoLabel)
        infoLabel.pinCenter()
        infoLabel.numberOfLines = 0
    }
    
    // MARK: - UI
    
    private func updateUI() {
        guard let projectManifest else { return }
        
        infoLabel.text = """
            Name: \(projectManifest.name)
            Created: \(projectManifest.createdAt)
            Image: \(projectManifest.image ?? "none")
            """
    }
    
    // MARK: - Data
    
    private func reloadData() {
        do {
            let projectManifest = try reader
                .getProjectManifest(for: projectURL)
            
            self.projectManifest = projectManifest
            updateUI()
            
        } catch { }
    }
    
}
