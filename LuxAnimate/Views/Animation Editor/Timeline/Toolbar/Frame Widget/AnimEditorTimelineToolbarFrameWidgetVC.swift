//
//  AnimEditorTimelineToolbarFrameWidgetVC.swift
//

import UIKit

extension AnimEditorTimelineToolbarFrameWidgetVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeFocusedFrameIndex(
            _ vc: AnimEditorTimelineToolbarFrameWidgetVC,
            _ focusedFrameIndex: Int)
        
    }
    
}

class AnimEditorTimelineToolbarFrameWidgetVC: UIViewController {
    
    private let controlVC = AnimEditorTimelineToolbarFrameWidgetControlVC()
    
    weak var delegate: Delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlVC.delegate = self
        addChild(controlVC, to: view)
    }
    
    func update(
        timelineViewModel: AnimEditorTimelineViewModel
    ) {
        controlVC.setFrameCount(
            timelineViewModel.frames.count)
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        controlVC.setFocusedFrameIndex(focusedFrameIndex)
    }
    
}

// MARK: - Delegates


extension AnimEditorTimelineToolbarFrameWidgetVC:
    AnimEditorTimelineToolbarFrameWidgetControlVC.Delegate {
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineToolbarFrameWidgetControlVC,
        _ focusedFrameIndex: Int
    ) {
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
}
