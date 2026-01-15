//
//  AnimEditorToolSidebarSliderContainer.swift
//

import UIKit

extension AnimEditorToolSidebarSlider {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeValue(
            _ v: AnimEditorToolSidebarSlider)
        
    }
    
    enum ValueDisplayMode {
        case percent(minValue: Int)
    }
    
}

class AnimEditorToolSidebarSlider: UIView {
    
    weak var delegate: Delegate?
    
    private let gamma: Double
    
    private let sliderBar =
        AnimEditorToolSidebarSliderBar()
    
    private let popupView:
        AnimEditorToolSidebarSliderPopupView
    
    init(
        title: String,
        gamma: Double,
        valueDisplayMode: ValueDisplayMode
    ) {
        self.gamma = gamma
        
        popupView = AnimEditorToolSidebarSliderPopupView(
            title: title,
            valueDisplayMode: valueDisplayMode)
        
        super.init(frame: .zero)
        
        addSubview(sliderBar)
        sliderBar.pinEdges()
        
        addSubview(popupView)
        popupView.pin(.centerY)
        popupView.pin(.leading, toAnchor: .trailing)
        
        sliderBar.delegate = self
        
        popupView.updateValue(0)
        popupView.setVisible(false, animated: false)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var value: Double {
        get {
            pow(sliderBar.value, gamma)
        }
        set {
            sliderBar.value = pow(newValue, 1/gamma)
        }
    }
    
}

extension AnimEditorToolSidebarSlider:
    AnimEditorToolSidebarSliderBar.Delegate {
    
    func onBeginPress(
        _ v: AnimEditorToolSidebarSliderBar
    ) {
        popupView.setVisible(true, animated: true)
    }
    
    func onEndPress(
        _ v: AnimEditorToolSidebarSliderBar
    ) {
        popupView.setVisible(false, animated: true)
    }
    
    func onChangeValue(
        _ v: AnimEditorToolSidebarSliderBar
    ) {
        popupView.updateValue(value)
        delegate?.onChangeValue(self)
    }
    
}
