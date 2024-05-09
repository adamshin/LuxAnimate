//
//  EditorFrameContentVC.swift
//

import UIKit

class EditorFrameContentVC: UIViewController {
    
    let canvasVC = EditorFrameCanvasVC()
    let toolbarVC = EditorFrameToolbarVC()
    let toolOverlayVC = EditorBrushToolOverlayVC()
    
    let canvasSafeAreaView = PassthroughView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(canvasVC, to: view)
        
        let toolbarContainer = UIView()
        view.addSubview(toolbarContainer)
        toolbarContainer.pinEdges([.horizontal, .top])
        
        addChild(toolbarVC, to: toolbarContainer)
        
        view.addSubview(canvasSafeAreaView)
        canvasSafeAreaView.pinEdges(.horizontal)
        canvasSafeAreaView.pin(.top, to: toolbarContainer, toAnchor: .bottom)
        canvasSafeAreaView.pin(.bottom, priority: .defaultLow)
        
        addChild(toolOverlayVC, to: canvasSafeAreaView)
        
        canvasVC.setSafeAreaReferenceView(canvasSafeAreaView)
    }
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        canvasSafeAreaView.pin(.bottom, to: bottomInsetView, toAnchor: .top)
    }
    
    func handleChangeBottomInsetViewFrame() {
        view.layoutIfNeeded()
        canvasVC.handleChangeSafeAreaReferenceViewFrame()
    }
    
}
