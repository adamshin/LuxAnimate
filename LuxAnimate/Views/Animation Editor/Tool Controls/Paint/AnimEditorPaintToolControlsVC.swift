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
    
    private let sidebarControlsView = AnimEditorPaintToolSidebarControlsView()
    private let expandedControlsView = AnimEditorPaintToolExpandedControlsView()
    
    private var isShowingExpandedControls = false
    
    weak var delegate: Delegate?
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(sidebarControlsView)
        sidebarControlsView.pinEdges(.leading)
        sidebarControlsView.pin(.centerY)
        
        view.addSubview(expandedControlsView)
        expandedControlsView.pinEdges(.leading)
        expandedControlsView.pin(.centerY)
        expandedControlsView.isHidden = true
        
        sidebarControlsView.delegate = self
        expandedControlsView.delegate = self
    }
    
    func setScale(_ value: Double) {
        sidebarControlsView.setScale(value)
    }
    
    func setSmoothing(_ value: Double) {
        sidebarControlsView.setSmoothing(value)
    }
    
    func toggleExpandedControls() {
        isShowingExpandedControls.toggle()
        sidebarControlsView.isHidden = isShowingExpandedControls
        expandedControlsView.isHidden = !isShowingExpandedControls
    }
    
}

extension AnimEditorPaintToolControlsVC:
    AnimEditorPaintToolSidebarControlsView.Delegate {
    
    func onChangeScale(
        _ view: AnimEditorPaintToolSidebarControlsView,
        _ value: Double
    ) {
        delegate?.onChangeScale(self, value)
    }
    
    func onChangeSmoothing(
        _ view: AnimEditorPaintToolSidebarControlsView,
        _ value: Double
    ) {
        delegate?.onChangeSmoothing(self, value)
    }
    
}

extension AnimEditorPaintToolControlsVC:
    AnimEditorPaintToolExpandedControlsView.Delegate {
    
    func onSelectBrush(
        _ view: AnimEditorPaintToolExpandedControlsView,
        id: String
    ) {
        delegate?.onSelectBrush(self, id: id)
    }
    
}
