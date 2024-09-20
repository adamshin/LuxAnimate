//
//  AnimEditorTimelineTrackVC.swift
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

extension AnimEditorTimelineTrackVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onBeginFrameScroll(
            _ vc: AnimEditorTimelineTrackVC)
        
        func onEndFrameScroll(
            _ vc: AnimEditorTimelineTrackVC)
        
        func onChangeFocusedFrameIndex(
            _ vc: AnimEditorTimelineTrackVC,
            _ focusedFrameIndex: Int)
        
        func onSelectFocusedFrame(
            _ vc: AnimEditorTimelineTrackVC,
            frameIndex: Int)
        
        func onLongPressFrame(
            _ vc: AnimEditorTimelineTrackVC,
            frameIndex: Int)
        
        func assetData(
            _ vc: AnimEditorTimelineTrackVC,
            assetID: String
        ) -> Data?
        
    }
    
}

class AnimEditorTimelineTrackVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private lazy var collectionView = TouchCancellingCollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout)
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = cellSpacing
        return layout
    }()
    
    private let cellRegistration = UICollectionView.CellRegistration<
        AnimEditorTimelineTrackCell,
        AnimEditorTimelineModel.Frame
    > { cell, indexPath, item in }
    
    private let dot = CircleView()
    
    private var model: AnimEditorTimelineModel = .empty
    private var focusedFrameIndex = 0
    
    private var isScrolling = false
    private var isScrollDrivingFocusedFrame = false
    
    private var openMenuFrameIndex: Int?
    
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
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        view.layoutIfNeeded()
        focusFrame(at: focusedFrameIndex, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalculateCollectionViewInsets()
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
    
    private func updateDot() {
        if let openMenuFrameIndex {
            if abs(openMenuFrameIndex - focusedFrameIndex) < 2 {
                setDotVisible(false)
            }
        } else {
            setDotVisible(true)
        }
    }
    
    private func setDotVisible(_ visible: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.dot.alpha = visible ? 1 : 0
        }
    }
    
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
        guard let frameIndex = currentFocusedFrameIndex()
        else { return }
        
        if focusedFrameIndex != frameIndex {
            focusedFrameIndex = frameIndex
            delegate?.onChangeFocusedFrameIndex(
                self, frameIndex)
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
    
    private func focusFrame(at index: Int, animated: Bool) {
        let clampedIndex = clamp(index,
            min: 0,
            max: model.frames.count - 1)
        
        focusedFrameIndex = clampedIndex
        
        if animated {
            isScrolling = true
            isScrollDrivingFocusedFrame = false
            collectionView.isUserInteractionEnabled = false
            
            delegate?.onBeginFrameScroll(self)
            
        } else {
            isScrolling = false
            isScrollDrivingFocusedFrame = false
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: clampedIndex, section: 0),
            at: .centeredHorizontally,
            animated: animated)
        
        updateVisibleCellsPlusButton(animated: animated)
    }
    
    // MARK: - Cells
    
    private func updateVisibleCellsContent() {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? AnimEditorTimelineTrackCell,
                let indexPath = collectionView.indexPath(for: cell)
            else { continue }
            
            let index = indexPath.item
            let frame = model.frames[index]
            
            cell.updateContent(frame: frame)
        }
    }
    
    private func updateVisibleCellsPlusButton(animated: Bool) {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? AnimEditorTimelineTrackCell
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
        cell: AnimEditorTimelineTrackCell,
        index: Int,
        animated: Bool
    ) {
        let frame = model.frames[index]
        
        let isFocused = index == focusedFrameIndex
        let isMenuOpen = index == openMenuFrameIndex
        let hasDrawing = frame.hasDrawing
        
        let plusIconVisible =
            isFocused &&
            !isScrolling &&
            !isMenuOpen &&
            !hasDrawing
        
        cell.setPlusIconVisible(
            plusIconVisible,
            withAnimation: animated)
    }
    
    // MARK: - Interface
    
    func setTimelineModel(_ model: AnimEditorTimelineModel) {
        let oldModel = self.model
        self.model = model
        
        if oldModel.frames.count != model.frames.count {
            collectionView.reloadData()
        } else {
            updateVisibleCellsContent()
            updateVisibleCellsPlusButton(animated: true)
        }
    }
    
    func setFocusedFrameIndex(_ frameIndex: Int) {
        focusFrame(at: frameIndex, animated: false)
    }
    
    func setOpenMenuFrameIndex(_ frameIndex: Int?) {
        openMenuFrameIndex = frameIndex
        
        updateDot()
        updateVisibleCellsPlusButton(animated: true)
    }
    
    func setPlaying(_ playing: Bool) {
        view.isUserInteractionEnabled = !playing
        
        if playing {
            collectionView.setContentOffset(
                collectionView.contentOffset,
                animated: false)
        }
    }
    
    func setFrameScrollEnabled(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
    
    func cell(at index: Int) -> AnimEditorTimelineTrackCell? {
        collectionView.cellForItem(
            at: IndexPath(item: index, section: 0))
            as? AnimEditorTimelineTrackCell
    }
    
}

// MARK: - Collection View

extension AnimEditorTimelineTrackVC: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        model.frames.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let item = model.frames[indexPath.item]
        
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item)
        
        cell.delegate = self
        return cell
    }
    
}

extension AnimEditorTimelineTrackVC: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? AnimEditorTimelineTrackCell
        else { return }
        
        let index = indexPath.item
        let frame = model.frames[index]
        
        cell.updateContent(frame: frame)
        
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
        delegate?.onBeginFrameScroll(self)
        
        updateVisibleCellsPlusButton(animated: true)
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
        isScrolling = decelerate
        isScrollDrivingFocusedFrame = decelerate
        if !decelerate {
            delegate?.onEndFrameScroll(self)
        }
        
        updateVisibleCellsPlusButton(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
        isScrollDrivingFocusedFrame = false
        delegate?.onEndFrameScroll(self)
        
        collectionView.isUserInteractionEnabled = true
        updateVisibleCellsPlusButton(animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        isScrollDrivingFocusedFrame = false
        delegate?.onEndFrameScroll(self)
        
        collectionView.isUserInteractionEnabled = true
        updateVisibleCellsPlusButton(animated: true)
    }
    
}

// MARK: - Cell Delegate

extension AnimEditorTimelineTrackVC:
    AnimEditorTimelineTrackCell.Delegate {
    
    func onSelect(_ cell: AnimEditorTimelineTrackCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let frameIndex = indexPath.item
        
        if frameIndex == focusedFrameIndex {
            delegate?.onSelectFocusedFrame(self, frameIndex: frameIndex)
        } else {
            focusFrame(at: frameIndex, animated: true)
            delegate?.onChangeFocusedFrameIndex(self, focusedFrameIndex)
        }
    }
    
    func onLongPress(_ cell: AnimEditorTimelineTrackCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let frameIndex = indexPath.item
        delegate?.onLongPressFrame(self, frameIndex: frameIndex)
    }
    
    func assetData(
        _ cell: AnimEditorTimelineTrackCell,
        assetID: String
    ) -> Data? {
        delegate?.assetData(self, assetID: assetID)
    }
    
}
