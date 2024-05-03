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
    
    func onUpdateSelectedFrame(_ vc: TimelineTrackVC)
    
    func onTapFrame(_ vc: TimelineTrackVC, index: Int)
    
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
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout)
    
    private let dot = CircleView()
    
    private var frameCount = 0
    
    private(set) var selectedFrameIndex = 0 {
        didSet {
            delegate?.onUpdateSelectedFrame(self)
        }
    }
    
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCollectionViewInsets()
        updateSelectedFrameIndex()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let index = selectedFrameIndex
        coordinator.animate { _ in
            self.selectFrame(at: index, animated: false)
        }

    }
    
    // MARK: - UI
    
    private func updateCollectionViewInsets() {
        let width = view.bounds.width
        let hInset = (width - cellSize.width) / 2
        
        collectionView.contentInset = UIEdgeInsets(
            top: trackTopInset,
            left: hInset,
            bottom: trackBottomInset,
            right: hInset)
    }
    
    private func updateSelectedFrameIndex() {
        guard let index = getSelectedFrameIndex() else { return }
        selectedFrameIndex = index
    }
    
    private func getSelectedFrameIndex() -> Int? {
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
    
    // MARK: - Interface
    
    func setFrameCount(_ frameCount: Int) {
        self.frameCount = frameCount
        collectionView.reloadData()
    }
    
    func selectFrame(at index: Int, animated: Bool) {
        let clampedIndex = clamp(index, min: 0, max: frameCount - 1)
        
        collectionView.scrollToItem(
            at: IndexPath(item: clampedIndex, section: 0),
            at: .centeredHorizontally,
            animated: animated)
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
        
        collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath, 
            item: indexPath.item)
    }
    
}

extension TimelineTrackVC: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.onTapFrame(self, index: indexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedFrameIndex()
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
