//
//  AnimEditorPaintToolControlsVC.swift
//

import UIKit

extension AnimEditorPaintToolControlsVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBrush(
            _ vc: AnimEditorPaintToolControlsVC,
            id: String)
        func onChangeScale(
            _ vc: AnimEditorPaintToolControlsVC,
            _ value: Double)
        func onChangeSmoothing(
            _ vc: AnimEditorPaintToolControlsVC,
            _ value: Double)
        
    }
    
}

class AnimEditorPaintToolControlsVC: UIViewController {
    
    private let sidebarControlsVC = AnimEditorPaintToolSidebarControlsVC()
    private let expandedControlsVC = AnimEditorPaintToolExpandedControlsVC()
    
    private var isExpandedControlsVisible = false
    
    weak var delegate: Delegate?
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        addChild(sidebarControlsVC, to: view)
        addChild(expandedControlsVC, to: view)
        
        sidebarControlsVC.delegate = self
        expandedControlsVC.delegate = self
        
        setExpandedControlsVisible(false)
    }
    
    private func setExpandedControlsVisible(
        _ isExpandedControlsVisible: Bool
    ) {
        self.isExpandedControlsVisible = isExpandedControlsVisible
        sidebarControlsVC.view.isHidden = isExpandedControlsVisible
        expandedControlsVC.view.isHidden = !isExpandedControlsVisible
    }
    
    func setScale(_ value: Double) {
        sidebarControlsVC.setScale(value)
    }
    
    func setSmoothing(_ value: Double) {
        sidebarControlsVC.setSmoothing(value)
    }
    
    func toggleExpandedControls() {
        setExpandedControlsVisible(!isExpandedControlsVisible)
    }
    
}

extension AnimEditorPaintToolControlsVC:
    AnimEditorPaintToolSidebarControlsVC.Delegate {
    
    func onChangeScale(
        _ vc: AnimEditorPaintToolSidebarControlsVC,
        _ value: Double
    ) {
        delegate?.onChangeScale(self, value)
    }
    
    func onChangeSmoothing(
        _ vc: AnimEditorPaintToolSidebarControlsVC,
        _ value: Double
    ) {
        delegate?.onChangeSmoothing(self, value)
    }
    
}

extension AnimEditorPaintToolControlsVC:
    AnimEditorPaintToolExpandedControlsVC.Delegate {
    
    func onSelectBrush(
        _ vc: AnimEditorPaintToolExpandedControlsVC,
        id: String
    ) {
        delegate?.onSelectBrush(self, id: id)
        toggleExpandedControls()
    }
    
}
