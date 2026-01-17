//
//  AnimEditorPaintToolExpandedControlsVC.swift
//

import UIKit

extension AnimEditorPaintToolExpandedControlsVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBrush(
            _ vc: AnimEditorPaintToolExpandedControlsVC,
            id: String)
        
    }
    
}

class AnimEditorPaintToolExpandedControlsVC: UIViewController {
    
    private let bodyView = AnimEditorPaintToolExpandedControlsView()
    
    weak var delegate: Delegate?
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyView.delegate = self
    }
    
}

extension AnimEditorPaintToolExpandedControlsVC:
    AnimEditorPaintToolExpandedControlsView.Delegate {
    
    func onSelectBrush(
        _ view: AnimEditorPaintToolExpandedControlsView,
        id: String
    ) {
        delegate?.onSelectBrush(self, id: id)
    }
    
}
