//
//  AppVC.swift
//

import UIKit

class AppVC: UIViewController {
    
    private let libraryVC = LibraryVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(libraryVC, to: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TESTING
        let editorVC = EditorVC(projectID: "")
        editorVC.modalPresentationStyle = .fullScreen
        present(editorVC, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
}
