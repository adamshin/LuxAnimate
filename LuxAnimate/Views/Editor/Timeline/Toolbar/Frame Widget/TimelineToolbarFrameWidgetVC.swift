//
//  TimelineToolbarFrameWidget.swift
//

import UIKit

private let buttonWidth: CGFloat = 64
private let frameButtonWidth: CGFloat = 88

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

private let numberFont = UIFont.monospacedDigitSystemFont(
    ofSize: 17,
    weight: .medium)

protocol TimelineToolbarFrameWidgetVCDelegate: AnyObject {
    
    func onBeginFrameScroll(_ vc: TimelineToolbarFrameWidgetVC)
    func onEndFrameScroll(_ vc: TimelineToolbarFrameWidgetVC)
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetVC,
        index: Int)
    
}

class TimelineToolbarFrameWidgetVC: UIViewController {
    
    weak var delegate: TimelineToolbarFrameWidgetVCDelegate?
    
    private let scrubberVC = TimelineToolbarFrameWidgetScrubberVC()
    
    /*
    private let frameNumberLabel = UILabel()
    
    private let previousFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.left",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    private let nextFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.pinWidth(to: 200)
        
        scrubberVC.delegate = self
        addChild(scrubberVC, to: view)
        
        /*
        let stack = UIStackView()
        stack.axis = .horizontal
        
        view.addSubview(stack)
        stack.pinEdges()
        
        stack.addArrangedSubview(previousFrameButton)
        
        let frameButtonContainer = UIView()
        stack.addArrangedSubview(frameButtonContainer)
        frameButtonContainer.pinWidth(to: frameButtonWidth)
        
        let frameLozenge = CircleView()
        frameLozenge.layer.cornerCurve = .continuous
        frameButtonContainer.addSubview(frameLozenge)
        frameLozenge.pinEdges(.horizontal)
        frameLozenge.pin(.centerY)
        frameLozenge.pinHeight(to: 32)
        frameLozenge.backgroundColor = UIColor(white: 1, alpha: 0.15)
        
        frameButtonContainer.addSubview(frameNumberLabel)
        frameNumberLabel.pinCenter()
        frameNumberLabel.font = numberFont
        frameNumberLabel.textColor = .editorLabel
        
        stack.addArrangedSubview(nextFrameButton)
        
        previousFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPreviousFrame(self)
        }
        nextFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectNextFrame(self)
        }
         */
    }
    
//    func setFocusedFrameIndex(_ index: Int) {
//        frameNumberLabel.text = "\(index + 1)"
//    }
    
    func setFrameCount(_ frameCount: Int) {
        scrubberVC.setFrameCount(frameCount)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        scrubberVC.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
        view.isUserInteractionEnabled = !playing
    }
    
}

extension TimelineToolbarFrameWidgetVC: 
    TimelineToolbarFrameWidgetScrubberVCDelegate {
    
    func onBeginFrameScroll(
        _ vc: TimelineToolbarFrameWidgetScrubberVC
    ) {
        // TODO: Hide buttons, show popup
        delegate?.onBeginFrameScroll(self)
    }
    
    func onEndFrameScroll(
        _ vc: TimelineToolbarFrameWidgetScrubberVC
    ) {
        delegate?.onEndFrameScroll(self)
    }
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetScrubberVC,
        index: Int
    ) {
        // TODO: update this view's ui
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
}
