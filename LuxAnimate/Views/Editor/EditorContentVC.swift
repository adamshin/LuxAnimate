//
//  EditorContentVC.swift
//

import UIKit

protocol EditorContentVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: EditorContentVC)
    func onSelectBrush(_ vc: EditorContentVC)
    func onSelectClear(_ vc: EditorContentVC)
    
    func needsDrawCanvas(_ vc: EditorContentVC)
    
}

class EditorContentVC: UIViewController {
    
    weak var delegate: EditorContentVCDelegate?
    
    weak var brushGestureDelegate: BrushGestureRecognizerGestureDelegate? {
        didSet {
            canvasVC.brushGestureDelegate = brushGestureDelegate
        }
    }
    
    private let canvasVC = EditorCanvasVC()
    private let timelineVC = EditorTimelineVC()
    private let titleBarVC = EditorTitleBarVC()
    
    private let brushToolOverlayVC = EditorBrushToolOverlayVC()
    
    private let canvasOverlayContainer = PassthroughView()
    private let canvasBoundsReferenceView = UIView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasVC.delegate = self
        timelineVC.delegate = self
        titleBarVC.delegate = self
        
        addChild(canvasVC, to: view)
        addChild(timelineVC, to: view)
        
        let titleStack = PassthroughStackView()
        titleStack.axis = .vertical
        timelineVC.remainderAreaView.addSubview(titleStack)
        titleStack.pinEdges()
        
        let titleContainer = UIView()
        titleStack.addArrangedSubview(titleContainer)
        addChild(titleBarVC, to: titleContainer)
        
        titleStack.addArrangedSubview(canvasOverlayContainer)
        addChild(brushToolOverlayVC, to: canvasOverlayContainer)
        
        canvasBoundsReferenceView.isUserInteractionEnabled = false
        canvasOverlayContainer.addSubview(canvasBoundsReferenceView)
        canvasBoundsReferenceView.pinEdges()
    }
    
    // MARK: - Interface
    
    func setCanvasSize(_ canvasSize: PixelSize) {
        canvasVC.setCanvasSize(canvasSize)
    }
    
}

// MARK: - Delegates

extension EditorContentVC: EditorCanvasVCDelegate {
    
    func canvasBoundsReferenceView(_ vc: EditorCanvasVC) -> UIView? {
        canvasBoundsReferenceView
    }
    
    func needsDrawCanvas(_ vc: EditorCanvasVC) {
        delegate?.needsDrawCanvas(self)
    }
    
}

extension EditorContentVC: EditorTimelineVCDelegate {
    
    func onModifyConstraints(_ vc: EditorTimelineVC) {
        canvasVC.handleUpdateBoundsReferenceView()
    }
    
}

extension EditorContentVC: EditorTitleBarVCDelegate {
    
    func onSelectBack(_ vc: EditorTitleBarVC) {
        delegate?.onSelectBack(self)
    }
    
    func onSelectBrush(_ vc: EditorTitleBarVC) {
        delegate?.onSelectBrush(self)
    }
    
    func onSelectClear(_ vc: EditorTitleBarVC) {
        delegate?.onSelectClear(self)
    }
    
}
