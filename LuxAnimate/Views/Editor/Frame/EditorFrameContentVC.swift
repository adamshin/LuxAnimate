//
//  EditorFrameContentVC.swift
//

import UIKit

class EditorFrameContentVC: UIViewController {
    
    let canvasVC = EditorFrameCanvasVC()
    let topBarVC = EditorFrameTopBarVC()
    let toolOverlayVC = EditorBrushToolOverlayVC()
    
    let canvasSafeAreaView = PassthroughView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(canvasVC, to: view)
        
        let topBarContainer = UIView()
        view.addSubview(topBarContainer)
        topBarContainer.pinEdges([.horizontal, .top])
        
        addChild(topBarVC, to: topBarContainer)
        
        view.addSubview(canvasSafeAreaView)
        canvasSafeAreaView.pinEdges(.horizontal)
        canvasSafeAreaView.pin(.top, to: topBarContainer, toAnchor: .bottom)
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
