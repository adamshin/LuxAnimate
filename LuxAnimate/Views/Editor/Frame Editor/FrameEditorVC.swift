//
//  FrameEditorVC.swift
//

import UIKit
import MetalKit

private let viewportSize = CGSize(
    width: 1920,
    height: 1080)

private let viewportPixelScale: CGFloat = 2

class FrameEditorVC: UIViewController {
    
    private let metalView: FrameEditorMetalView
    
    private let frameEditor: FrameEditor
//    private let frameRenderer: FrameRenderer
    
    // MARK: - Init
    
    init() {
//        let drawableSize = CGSize(
//            width: viewportSize.width * viewportPixelScale,
//            height: viewportSize.height * viewportPixelScale)
        
        metalView = FrameEditorMetalView()
        
        frameEditor = FrameEditor()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.pinWidth(to: viewportSize.width)
        view.pinHeight(to: viewportSize.height)
        
        view.addSubview(metalView)
        metalView.pinEdges()
    }
    
}
