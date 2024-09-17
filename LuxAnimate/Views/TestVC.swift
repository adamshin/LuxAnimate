//
//  TestVC.swift
//

import UIKit

class TestVC: UIViewController {
    
    private let timelineVC: AnimEditorTimelineVC
    
    init() {
        let frames = (1...50).map { _ in
            AnimEditorTimelineModel.Frame(
                hasDrawing: false,
                thumbnailURL: nil)
        }
        let timelineModel = AnimEditorTimelineModel(frames: frames)
        
        timelineVC = AnimEditorTimelineVC(
            timelineModel: timelineModel,
            focusedFrameIndex: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        addChild(timelineVC, to: view)
    }
    
}
