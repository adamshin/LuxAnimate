//
//  AnimEditorTimelineToolbarFrameWidgetVC.swift
//

import UIKit

extension AnimEditorTimelineToolbarFrameWidgetVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeFocusedFrame(
            _ vc: AnimEditorTimelineToolbarFrameWidgetVC,
            frameIndex: Int)
        
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
    
    func setFrameCount(_ frameCount: Int) {
        controlVC.setFrameCount(frameCount)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        controlVC.setFocusedFrameIndex(index)
    }
    
}

// MARK: - Delegates


extension AnimEditorTimelineToolbarFrameWidgetVC:
    AnimEditorTimelineToolbarFrameWidgetControlVC.Delegate {
    
    func onChangeFocusedFrame(
        _ vc: AnimEditorTimelineToolbarFrameWidgetControlVC,
        index: Int
    ) {
        delegate?.onChangeFocusedFrame(
            self, frameIndex: index)
    }
    
}
