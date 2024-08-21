//
//  AppVC.swift
//

import UIKit

class AppVC: UIViewController {
    
//    private let libraryVC = LibraryVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addChild(libraryVC, to: view)
        
        let vc = TestWorkspaceVC()
        addChild(vc, to: view)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
}
