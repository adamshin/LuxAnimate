//
//  EditorBrushToolOverlayVC.swift
//

import UIKit

class EditorBrushToolOverlayVC: UIViewController {
    
    private let slider = SliderView1()
//    private let slider = SliderView2()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(slider)
        slider.pinEdges(.leading, padding: 12)
        slider.pin(.centerY)
    }
    
}

// MARK: - Sliders

private class SliderView1: UIView {
    
    private let padding: CGFloat = 4
    private let nubHeight: CGFloat = 20
    
    private let backgroundView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemMaterialDark))
    
    private let shadowView = UIView()
    
    private let nubView = CircleView()
    
    init() {
        super.init(frame: .zero)
        
        pinWidth(to: 48)
        pinHeight(to: 180)
        
        addSubview(shadowView)
        shadowView.layer.cornerCurve = .continuous
        shadowView.backgroundColor = UIColor(white: 1, alpha: 0.15)
//        shadowView.layer.borderWidth = 1
//        shadowView.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        
        addSubview(backgroundView)
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.masksToBounds = true
        
        addSubview(nubView)
        nubView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        nubView.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        shadowView.frame = bounds
            .insetBy(dx: -1, dy: -1)
        
        nubView.frame = CGRect(
            center: CGPoint(
                x: bounds.midX,
                y: bounds.maxY - nubHeight/2 - padding - 80),
            size: CGSize(
                width: bounds.width - padding * 2,
                height: nubHeight))
        
        let cornerRadius = nubHeight/2 + padding
        backgroundView.layer.cornerRadius = cornerRadius
        shadowView.layer.cornerRadius = cornerRadius + 1.5
    }
    
}

private class SliderView2: UIView {
    
    private let padding: CGFloat = 4
    private let nubHeight: CGFloat = 20
    
    private let backgroundView = UIView()
    private let shadowView = UIView()
    
    private let nubView = CircleView()
    
    init() {
        super.init(frame: .zero)
        
        pinWidth(to: 48)
        pinHeight(to: 180)
        
        addSubview(shadowView)
        shadowView.layer.cornerCurve = .continuous
        shadowView.layer.borderWidth = 1
        shadowView.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
        
        addSubview(backgroundView)
        backgroundView.backgroundColor = UIColor(white: 0.25, alpha: 0.8)
        backgroundView.layer.cornerCurve = .continuous
        
        addSubview(nubView)
        nubView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        nubView.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        shadowView.frame = bounds
            .insetBy(dx: -1, dy: -1)
        
        nubView.frame = CGRect(
            center: CGPoint(
                x: bounds.midX,
                y: bounds.maxY - nubHeight/2 - padding - 80),
            size: CGSize(
                width: bounds.width - padding * 2,
                height: nubHeight))
        
        let cornerRadius = nubHeight/2 + padding
        backgroundView.layer.cornerRadius = cornerRadius
        shadowView.layer.cornerRadius = cornerRadius + 1.5
    }
    
}
