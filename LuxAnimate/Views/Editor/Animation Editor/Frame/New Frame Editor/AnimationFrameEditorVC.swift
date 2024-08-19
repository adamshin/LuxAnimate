//
//  AnimationFrameEditorVC.swift
//

import UIKit

protocol AnimationFrameEditorVCDelegate: AnyObject {
    
    func onSelectUndo(_ vc: AnimationFrameEditorVC)
    func onSelectRedo(_ vc: AnimationFrameEditorVC)
    
}

class AnimationFrameEditorVC: UIViewController {
    
    weak var delegate: AnimationFrameEditorVCDelegate?
    
    private let canvasVC = AnimationFrameEditorCanvasVC()
    
    private let projectID: String
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasVC.delegate = self
        addChild(canvasVC, to: view)
        
        canvasVC.setCanvasSize(
            PixelSize(width: 200, height: 200))
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

extension AnimationFrameEditorVC: AnimationFrameEditorCanvasVCDelegate {
    
    func onSelectUndo(_ vc: AnimationFrameEditorCanvasVC) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ vc: AnimationFrameEditorCanvasVC) {
        delegate?.onSelectRedo(self)
    }
    
}
