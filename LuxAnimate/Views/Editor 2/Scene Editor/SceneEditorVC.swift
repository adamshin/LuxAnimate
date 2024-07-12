//
//  SceneEditorVC.swift
//

import UIKit

class SceneEditorVC: UIViewController {
    
    private let projectID: String
    private let sceneID: String
    
    init(projectID: String, sceneID: String) {
        self.projectID = projectID
        self.sceneID = sceneID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
    }
    
}
