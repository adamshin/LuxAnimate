//
//  TimelineToolbarFrameWidgetScrubberVC.swift
//

import UIKit

private let cellWidth: CGFloat = 24

protocol TimelineToolbarFrameWidgetScrubberVCDelegate: AnyObject {
    
    func onBeginFrameScroll(
        _ vc: TimelineToolbarFrameWidgetScrubberVC)
    
    func onEndFrameScroll(
        _ vc: TimelineToolbarFrameWidgetScrubberVC)
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetScrubberVC,
        index: Int)
    
}

class TimelineToolbarFrameWidgetScrubberVC: UIViewController {
    
    weak var delegate: TimelineToolbarFrameWidgetScrubberVCDelegate?
    
    private lazy var collectionView = ScrubberCollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout)
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    private let cellRegistration = UICollectionView.CellRegistration<
        TimelineToolbarFrameWidgetScrubberCell,
        Void
    > { cell, indexPath, _ in }
    
    private var cells: [TimelineToolbarFrameWidgetScrubberCell] = []
    
    let staticContentView = UIView()
    
    private var frameCount = 0
    
    private(set) var focusedFrameIndex = 0
    private var isScrollDrivingFocusedFrame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        view.addSubview(collectionView)
        collectionView.pinEdges()
        
        collectionView.backgroundColor = nil
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.addSubview(staticContentView)
        staticContentView.pinEdges(to: view)
        
        focusFrame(at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalculateCollectionViewInsets()
        recalculateFocusedFrame()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let index = focusedFrameIndex
        coordinator.animate { _ in
            self.focusFrame(at: index)
        }
    }
    
    // MARK: - UI
    
    private func recalculateCollectionViewInsets() {
        let width = view.bounds.width
        let hInset = (width - cellWidth) / 2
        
        collectionView.contentInset = UIEdgeInsets(
            top: 0, left: hInset,
            bottom: 0, right: hInset)
    }
    
    private func recalculateFocusedFrame() {
        guard let index = currentFocusedFrameIndex()
        else { return }
        
        if focusedFrameIndex != index {
            focusedFrameIndex = index
            delegate?.onChangeFocusedFrame(self, index: index)
        }
    }
    
    private func currentFocusedFrameIndex() -> Int? {
        collectionView.layoutIfNeeded()
        
        let scrollRectMidX =
            collectionView.contentOffset.x +
            collectionView.bounds.width / 2
        
        let cellsAndDistances = collectionView.visibleCells.map {
            ($0, abs($0.frame.midX - scrollRectMidX))
        }
        let selectedCell = cellsAndDistances
            .min { $0.1 < $1.1 }
            .map { $0.0 }
        
        guard let selectedCell else { return nil }
        
        let indexPath = collectionView.indexPath(for: selectedCell)
        return indexPath?.item
    }
    
    private func focusFrame(at index: Int) {
        let clampedIndex = clamp(index,
            min: 0,
            max: frameCount - 1)
        
        guard focusedFrameIndex != clampedIndex
        else { return }
        
        focusedFrameIndex = clampedIndex
        
        isScrollDrivingFocusedFrame = false
        collectionView.scrollToItem(
            at: IndexPath(item: clampedIndex, section: 0),
            at: .centeredHorizontally,
            animated: false)
    }
    
    // MARK: - Interface
    
    func setFrameCount(_ frameCount: Int) {
        if self.frameCount != frameCount {
            self.frameCount = frameCount
            collectionView.reloadData()
        }
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        focusFrame(at: index)
    }
    
    func setScrubberVisible(
        _ visible: Bool,
        animated: Bool
    ) {
        if animated {
            if visible {
                UIView.animate(withDuration: 0.1) {
//                    self.cells.forEach { $0.tick.alpha = 1 }
                    self.staticContentView.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.25) {
//                    self.cells.forEach { $0.tick.alpha = 0 }
                    self.staticContentView.alpha = 1
                }
            }
        } else {
//            cells.forEach { $0.tick.alpha = visible ? 1 : 0 }
            staticContentView.alpha = visible ? 0 : 1
        }
    }
    
}

// MARK: - Collection View

extension TimelineToolbarFrameWidgetScrubberVC:
    UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        frameCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath, 
            item: ())
        
        cells.append(cell)
//        cell.tick.alpha = 0
        return cell
    }
    
}

extension TimelineToolbarFrameWidgetScrubberVC:
    UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollDrivingFocusedFrame {
            recalculateFocusedFrame()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollDrivingFocusedFrame = true
        delegate?.onBeginFrameScroll(self)
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let target = targetContentOffset.pointee
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = target.x + collectionView.contentInset.left

        let targetRect = CGRect(
            x: target.x,
            y: 0,
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height)

        let layoutAttributes = collectionView.collectionViewLayout
            .layoutAttributesForElements(in: targetRect) ?? []

        for attribute in layoutAttributes {
            let itemOffset = attribute.frame.origin.x
            if abs(itemOffset - horizontalOffset) < abs(offsetAdjustment) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }
        
        targetContentOffset.pointee = CGPoint(
            x: target.x + offsetAdjustment,
            y: target.y)
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        isScrollDrivingFocusedFrame = decelerate
        if !decelerate {
            delegate?.onEndFrameScroll(self)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrollDrivingFocusedFrame = false
        delegate?.onEndFrameScroll(self)
    }
    
}

extension TimelineToolbarFrameWidgetScrubberVC:
    UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: cellWidth,
            height: collectionView.bounds.height)
    }
    
}

// MARK: - Helpers

class ScrubberCollectionView: UICollectionView {
    
    override func hitTest(
        _ point: CGPoint, with event: UIEvent?
    ) -> UIView? {
        for subview in subviews.reversed() {
            let p = subview.convert(point, from: self)
                
            if let view = subview.hitTest(p, with: event) {
                return view
            }
        }
        return self
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
    
}
