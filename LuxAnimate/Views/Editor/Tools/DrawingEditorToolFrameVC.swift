//
//  DrawingEditorToolFrameVC.swift
//

import UIKit

protocol DrawingEditorToolFrameVCDelegate: AnyObject {
    func onSelectBack(_ vc: DrawingEditorToolFrameVC)
    func onSelectClear(_ vc: DrawingEditorToolFrameVC)
}

class DrawingEditorToolFrameVC: UIViewController {
    
    weak var delegate: DrawingEditorToolFrameVCDelegate?
    
    private let titleBarVC = EditorTitleBarVC()
    private let brushOptionsVC = DrawingEditorBrushOptionsVC()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleBarContainer = UIView()
        view.addSubview(titleBarContainer)
        titleBarContainer.pinEdges([.horizontal, .top])
        
        let brushOptionsContainer = PassthroughView()
        view.addSubview(brushOptionsContainer)
        brushOptionsContainer.pinEdges([.horizontal, .bottom])
        brushOptionsContainer.pin(.top, to: titleBarContainer, toAnchor: .bottom)
        
        let strokeBlockerView = UIView()
        strokeBlockerView.backgroundColor = .clear
        view.addSubview(strokeBlockerView)
        strokeBlockerView.pinEdges(.horizontal)
        strokeBlockerView.pin(.top, to: view.safeAreaLayoutGuide, toAnchor: .bottom)
        strokeBlockerView.pin(.bottom, to: view, toAnchor: .bottom)
        
        addChild(titleBarVC, to: titleBarContainer)
        addChild(brushOptionsVC, to: brushOptionsContainer)
        
        titleBarVC.delegate = self
    }
    
    func hidePopups() {
        brushOptionsVC.setVisible(false)
    }
    
    var brushSize: Double { brushOptionsVC.brushSize }
    var smoothing: Double { brushOptionsVC.smoothing }
    
}

extension DrawingEditorToolFrameVC: EditorTitleBarVCDelegate {
    
    func onSelectBack(_ vc: EditorTitleBarVC) {
        delegate?.onSelectBack(self)
    }
    
    func onSelectClear(_ vc: EditorTitleBarVC) {
        delegate?.onSelectClear(self)
    }
    
    func onSelectBrush(_ vc: EditorTitleBarVC) {
        brushOptionsVC.toggleVisibility()
    }
    
}
