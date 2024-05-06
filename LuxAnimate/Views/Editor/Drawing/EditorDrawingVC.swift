//
//  EditorDrawingVC.swift
//

import UIKit
import Metal

// This view controller should contain logic for loading
// and displaying the contents of a single frame. It should
// coordinate with the frame cache system -- maybe that lives
// a layer up in the EditorVC?

// At any moment, the user may switch frames. We need to display
// the frame's content quickly. The process should look like this:

// 1) Display a cached preview image if one exists.
// 2) Load the contents of each layer at medium resolution.
// 3) Load the contents of the active layer at high resolution.
//    (at this point, editing is possible)

// There may be multiple caching systems at play here. We
// need to render and cache preview images a few frames
// ahead and behind the current frame. We may also want to
// render some very low-res preview images across the whole
// timeline, in case the user scrubs fast. Maybe these can
// be small enough to all stay in memory. Or maybe they need
// to be written to disk. We also will need to render frames
// to video for playback. Depending how fast this is, maybe
// it can be done in realtime or near-realtime? More likely,
// we'll need to prerender these video segments to disk. Too
// big to keep in memory at once.

// Maybe editing tools should live inside here as well.
// Probably easier than propagating all that interaction
// up to the EditorVC.

protocol EditorDrawingVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: EditorDrawingVC)
    
}

class EditorDrawingVC: UIViewController {
    
    weak var delegate: EditorDrawingVCDelegate?
    
    private let contentVC = EditorDrawingContentVC()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentVC.canvasVC.delegate = self
        contentVC.topBarVC.delegate = self
        
        addChild(contentVC, to: view)
        
        contentVC.canvasVC.setCanvasSize(
            PixelSize(width: 1920, height: 1080))
    }
    
    // MARK: - Interface
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        contentVC.setBottomInsetView(bottomInsetView)
    }
    
    func handleChangeBottomInsetViewFrame() {
        contentVC.handleChangeBottomInsetViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorDrawingVC: EditorDrawingCanvasVCDelegate {
    
}

extension EditorDrawingVC: EditorDrawingTopBarVCDelegate {
    
    func onSelectBack(_ vc: EditorDrawingTopBarVC) {
        delegate?.onSelectBack(self)
    }
    
    func onSelectBrush(_ vc: EditorDrawingTopBarVC) { }
    
}
