//
//  TimelineToolbarFrameWidget.swift
//

import UIKit

protocol TimelineToolbarFrameWidgetVCDelegate: AnyObject {
    
    func onBeginFrameScroll(_ vc: TimelineToolbarFrameWidgetVC)
    func onEndFrameScroll(_ vc: TimelineToolbarFrameWidgetVC)
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetVC,
        index: Int)
    
}

class TimelineToolbarFrameWidgetVC: UIViewController {
    
    weak var delegate: TimelineToolbarFrameWidgetVCDelegate?
    
//    private let scrubberVC = TimelineToolbarFrameWidgetScrubberVC()
    private let controlVC = TimelineToolbarFrameWidgetControlVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrubberVC.delegate = self
//        addChild(scrubberVC, to: view)
        
        controlVC.delegate = self
        addChild(controlVC, to: view)
        
//        scrubberVC.setScrubberVisible(false, animated: false)
    }
    
    func setFrameCount(_ frameCount: Int) {
//        scrubberVC.setFrameCount(frameCount)
        controlVC.setFrameCount(frameCount)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
//        scrubberVC.setFocusedFrameIndex(index)
        controlVC.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
        view.isUserInteractionEnabled = !playing
    }
    
}

// MARK: - Delegates

//extension TimelineToolbarFrameWidgetVC: 
//    TimelineToolbarFrameWidgetScrubberVCDelegate {
//    
//    func onBeginFrameScroll(
//        _ vc: TimelineToolbarFrameWidgetScrubberVC
//    ) {
//        scrubberVC.setScrubberVisible(true, animated: true)
//        delegate?.onBeginFrameScroll(self)
//    }
//    
//    func onEndFrameScroll(
//        _ vc: TimelineToolbarFrameWidgetScrubberVC
//    ) {
//        scrubberVC.setScrubberVisible(false, animated: true)
//        delegate?.onEndFrameScroll(self)
//    }
//    
//    func onChangeFocusedFrame(
//        _ vc: TimelineToolbarFrameWidgetScrubberVC,
//        index: Int
//    ) {
//        controlVC.setFocusedFrameIndex(index)
//        delegate?.onChangeFocusedFrame(self, index: index)
//    }
//    
//}

extension TimelineToolbarFrameWidgetVC:
    TimelineToolbarFrameWidgetControlVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetControlVC,
        index: Int
    ) {
//        scrubberVC.setFocusedFrameIndex(index)
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
}
