//
//  New≠DrawingEditorVC.swift
//

import UIKit

protocol DrawingEditorVCDelegate: AnyObject {
    func onSelectUndo(_ vc: DrawingEditorVC)
    func onSelectRedo(_ vc: DrawingEditorVC)
}

class DrawingEditorVC: UIViewController {
    
    weak var delegate: DrawingEditorVCDelegate?
    
    private let canvasVC = DrawingEditorCanvasVC()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasVC.delegate = self
        addChild(canvasVC, to: view)
    }
    
    // MARK: - Interface
    
    func setSafeAreaReferenceView(_ view: UIView) {
        canvasVC.setSafeAreaReferenceView(view)
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        canvasVC.handleChangeSafeAreaReferenceViewFrame()
    }
    
}

// MARK: - Delegates

extension DrawingEditorVC: DrawingEditorCanvasVCDelegate {
    
    func onSelectUndo(_ vc: DrawingEditorCanvasVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: DrawingEditorCanvasVC) {
        delegate?.onSelectRedo(self)
    }
    
}
