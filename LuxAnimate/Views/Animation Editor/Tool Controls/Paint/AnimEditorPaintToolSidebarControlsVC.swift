//
//  AnimEditorPaintToolSidebarControlsVC.swift
//

import UIKit

extension AnimEditorPaintToolSidebarControlsVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeScale(
            _ vc: AnimEditorPaintToolSidebarControlsVC,
            _ value: Double)
        func onChangeSmoothing(
            _ vc: AnimEditorPaintToolSidebarControlsVC,
            _ value: Double)
        
    }
    
}

class AnimEditorPaintToolSidebarControlsVC: UIViewController {
    
    private let bodyView = AnimEditorPaintToolSidebarControlsView()
    
    weak var delegate: Delegate?
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyView.delegate = self
    }
    
    func setScale(_ value: Double) {
        bodyView.setScale(value)
    }
    
    func setSmoothing(_ value: Double) {
        bodyView.setSmoothing(value)
    }
    
}

extension AnimEditorPaintToolSidebarControlsVC:
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
