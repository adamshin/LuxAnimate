//
//  TimelineTrackVC.swift
//

import UIKit

private let trackHeight: CGFloat = 64
private let trackTopInset: CGFloat = 32
private let trackBottomInset: CGFloat = 20

private let dotSize: CGFloat = 8

private let cellAspectRatio: CGFloat = 1
private let cellSize: CGSize = CGSize(
    width: trackHeight * cellAspectRatio,
    height: trackHeight)

private let cellSpacing: CGFloat = 8

protocol TimelineTrackVCDelegate: AnyObject {
    
    func onChangeFocusedFrame(_ vc: TimelineTrackVC)
    
    func onSelectFocusedFrame(_ vc: TimelineTrackVC)
    
    func onSelectFrame(_ vc: TimelineTrackVC, index: Int)
    func onLongPressFrame(_ vc: TimelineTrackVC, index: Int)
    
}

class TimelineTrackVC: UIViewController {
    
    weak var delegate: TimelineTrackVCDelegate?
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = cellSpacing
        return layout
    }()
    
    private let cellRegistration = UICollectionView.CellRegistration<
        TimelineTrackCell, Int
    > { cell, indexPath, item in
        cell.hasDrawing = item % 6 == 0
    }
    
    private lazy var collectionView = TouchCancellingCollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout)
    
    private let dot = CircleView()
    
    private var frameCount = 0
    private(set) var focusedFrameIndex = 0
    
    private var isScrolling = false
    private var isScrollDrivingFocusedFrame = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dot.backgroundColor = .editorLabel
        view.addSubview(dot)
        dot.pinSize(to: dotSize)
        dot.pinCenter(.horizontal)
        dot.pin(.centerY, toAnchor: .top, constant: trackTopInset / 2)
        
        view.addSubview(collectionView)
        collectionView.pinEdges()
        collectionView.pinHeight(
            to: trackHeight + trackTopInset + trackBottomInset)
        
        collectionView.backgroundColor = nil
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delaysContentTouches = false
        collectionView.allowsSelection = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        focusFrame(at: 0, animated: false)
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
            self.focusFrame(at: index, animated: false)
        }
    }
    
    // MARK: - UI
    
    private func recalculateCollectionViewInsets() {
        let width = view.bounds.width
        let hInset = (width - cellSize.width) / 2
        
        collectionView.contentInset = UIEdgeInsets(
            top: trackTopInset,
            left: hInset,
            bottom: trackBottomInset,
            right: hInset)
    }
    
    private func recalculateFocusedFrame() {
        guard let index = currentFocusedFrameIndex()
        else { return }
        
        if focusedFrameIndex != index {
            focusedFrameIndex = index
            delegate?.onChangeFocusedFrame(self)
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
    
    private func updateVisibleCellPlusButtons(animated: Bool) {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? TimelineTrackCell
            else { continue }
            
            guard let indexPath = collectionView.indexPath(for: cell)
            else { continue }
            
            updateCellPlusButton(
                cell: cell,
                index: indexPath.item,
                animated: animated)
        }
    }
    
    private func updateCellPlusButton(
        cell: TimelineTrackCell,
        index: Int,
        animated: Bool
    ) {
        if isScrolling {
            cell.setPlusIconVisible(false, withAnimation: animated)
        } else {
            let isFocused = index == focusedFrameIndex
            cell.setPlusIconVisible(isFocused, withAnimation: animated)
        }
    }
    
    // MARK: - Interface
    
    func setFrameCount(_ frameCount: Int) {
        self.frameCount = frameCount
        collectionView.reloadData()
        
        focusFrame(at: focusedFrameIndex, animated: false)
    }
    
    func focusFrame(at index: Int, animated: Bool) {
        let clampedIndex = clamp(index,
            min: 0, max: frameCount - 1)
        
        guard focusedFrameIndex != clampedIndex
        else { return }
        
        focusedFrameIndex = clampedIndex
        delegate?.onChangeFocusedFrame(self)
        
        isScrolling = animated
        isScrollDrivingFocusedFrame = !animated
        collectionView.isUserInteractionEnabled = !animated
        
        collectionView.scrollToItem(
            at: IndexPath(item: clampedIndex, section: 0),
            at: .centeredHorizontally,
            animated: animated)
        
        updateVisibleCellPlusButtons(animated: animated)
    }
    
    func setDotVisible(_ visible: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.dot.alpha = visible ? 1 : 0
        }
    }
    
    func cell(at index: Int) -> TimelineTrackCell? {
        collectionView.cellForItem(
            at: IndexPath(item: index, section: 0))
            as? TimelineTrackCell
    }
    
}

// MARK: - Collection View

extension TimelineTrackVC: UICollectionViewDataSource {
    
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
            item: indexPath.item)
        
        cell.delegate = self
        return cell
    }
    
}

extension TimelineTrackVC: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? TimelineTrackCell
        else { return }
        
        updateCellPlusButton(
            cell: cell,
            index: indexPath.item,
            animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollDrivingFocusedFrame {
            recalculateFocusedFrame()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
        isScrollDrivingFocusedFrame = true
        
        updateVisibleCellPlusButtons(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
        isScrollDrivingFocusedFrame = true
        
        collectionView.isUserInteractionEnabled = true
        updateVisibleCellPlusButtons(animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        isScrollDrivingFocusedFrame = true
        
        collectionView.isUserInteractionEnabled = true
        updateVisibleCellPlusButtons(animated: true)
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
    
}

// MARK: - Cell Delegate

extension TimelineTrackVC: TimelineTrackCellDelegate {
    
    func onSelect(_ cell: TimelineTrackCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let index = indexPath.item
        
        if index == focusedFrameIndex {
            delegate?.onSelectFocusedFrame(self)
        } else {
            delegate?.onSelectFrame(self, index: index)
        }
    }
    
    func onLongPress(_ cell: TimelineTrackCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let index = indexPath.item
        delegate?.onLongPressFrame(self, index: index)
    }
    
}
