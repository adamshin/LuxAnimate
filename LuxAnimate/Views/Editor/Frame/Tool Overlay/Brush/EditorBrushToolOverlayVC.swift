//
//  EditorBrushToolOverlayVC.swift
//

import UIKit

private let sizeGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class EditorBrushToolOverlayVC: UIViewController {
    
    private let sizeSlider = ToolOverlaySlider()
    private let smoothingSlider = ToolOverlaySlider()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.axis = .vertical
        view.addSubview(stack)
        stack.pinEdges(.leading)
        stack.pin(.centerY)
        
        stack.addArrangedSubview(sizeSlider)
        stack.addArrangedSubview(smoothingSlider)
    }
    
    var size: Double {
        get {
            pow(sizeSlider.value, sizeGamma)
        }
        set {
            sizeSlider.value = pow(newValue, 1/sizeGamma)
        }
    }
    
    var smoothing: Double {
        get {
            pow(smoothingSlider.value, smoothingGamma)
        }
        set {
            smoothingSlider.value = pow(newValue, 1/smoothingGamma)
        }
    }
    
}
