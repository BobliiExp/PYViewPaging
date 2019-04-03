//
//  PYViewPage.swift
//  PYViewPaging
//
//  Created by Bob Lee on 2019/3/30.
//  Copyright © 2019 Bob Lee. All rights reserved.
//

import UIKit
import AVFoundation

protocol PYViewPageDelegate: NSObjectProtocol {
    /**
     即将滚动到页面
     - Parameters:
     - index: 下一个页面索引
     - item: 下一个页面数据
     
     - Authors: Bob
     - Date: 2019
     */
    func willScrollToPage(_ index: Int, item: FXConfigCellModel)
    
    /**
     已经滚动到页面
     - Parameters:
     - index: 页面索引
     - item: 页面数据
     
     - Authors: Bob
     - Date: 2019
     */
    func didScrollToPage(_ index: Int, item: FXConfigCellModel)
    
    /**
     页面滑动中
     - Parameters:
     - offsetRatio: 当前页面滑动相对于正常页面位置的偏移比例（-1~1）
     
     - Authors: Bob
     - Date: 2019
     */
    func pageDidScroll(_ offsetRatio: CGFloat)
    
    /**
     页面选中了
     - Parameters:
     - index: 页面索引
     - item: 页面数据
     
     - Authors: Bob
     - Date: 2019
     */
    func pageDidSelected(_ index: Int, item: FXConfigCellModel)
}

/**
 实现分页效果
 
 能力：
 1.支持cell、vc的轮循展示
 2.关联pageControl
 3.支持自动适配大小
 4.支持视频、图片、gif等内容
 
 默认效果：
 1.背景阴影
 
 未来扩展：
 1.支持cell的展示效果多样化
 
 */
class PYViewPage: UIView {
    
    // MARK: - private properties
    fileprivate var _colloectionView: UICollectionView!
    fileprivate var _pageControl: PYViewPageControl!
    fileprivate var _dataPages: [FXConfigCellModel]?
    fileprivate weak var _delegate: PYViewPageDelegate?
    private let _cellIdentifier = "cellIdentifier"
    
    /** 所有需要的边距 */
    fileprivate let _paddingH: CGFloat = 21
    fileprivate var _pageWidth: CGFloat {
        return frame.width - _paddingH*4
    }
    fileprivate var _offsetXForCurrentPage: CGFloat {
        // 返回当前索引页面正常的x轴偏移
        return CGFloat(indexOfPage) * (_pageWidth + _paddingH) - _paddingH
    }
    fileprivate var _heightItem: CGFloat = 0
    private var _isFirstLoading = true

    // MARK: - public properties
    var indexOfPage: Int = 0
    /** 是否循环展示 */
    var isLoopPlay: Bool = false
    /** 是否自动轮播展示 */
    var isAutoPlay: Bool = false
    
    
    // MARK: - life cycle
    init(_ delegate: PYViewPageDelegate, heightItem: CGFloat) {
        super.init(frame: CGRect.init())
        
        _heightItem = heightItem
        _delegate = delegate
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: _paddingH, bottom: 0, right: _paddingH)
        layout.minimumLineSpacing = _paddingH
        
        _colloectionView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: layout)
        _colloectionView.showsHorizontalScrollIndicator = false
        _colloectionView.showsVerticalScrollIndicator = false
        _colloectionView.backgroundColor = UIColor.clear
        _colloectionView.contentInset = UIEdgeInsets.init(top: 0, left: _paddingH, bottom: 0, right: _paddingH)
//        _colloectionView.isPagingEnabled = true
        _colloectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.98) // 减速速度
        addSubview(_colloectionView)
        
        _colloectionView.register(PYViewPageCell.self, forCellWithReuseIdentifier: _cellIdentifier)
        _colloectionView.delegate = self
        _colloectionView.dataSource = self
        
        _colloectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
     
        _pageControl = PYViewPageControl.init(self)
        addSubview(_pageControl)
        
        _pageControl.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-61)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
    }
    
    func setupData(_ dataModels: [FXConfigCellModel]) {
        _isFirstLoading = true
        _dataPages = dataModels
        _colloectionView.reloadData()
        _pageControl.setupData(dataModels.count)
    }
    
}

/// public funcs
extension PYViewPage {
    func scrollToPage(_ index: Int, animation: Bool) {
        if index == indexOfPage { return }
        
        indexOfPage = index
        scrollToPage(true, shouldScroll: true, animation: animation)
    }
}

/// 处理collectionView回调逻辑
extension PYViewPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _dataPages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: _cellIdentifier, for: indexPath) as? PYViewPageCell
        if cell == nil {
            cell = PYViewPageCell.init(frame: CGRect.init())
        }
        
        if let model = _dataPages?[indexPath.row] {
            cell?.setupData(model)
            
            if _isFirstLoading {
                _isFirstLoading = false
                model.help?.play()
            }
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 这里才关联element
        if let temp = cell as? PYViewPageCell {
            temp.dataModel?.help?.pauseForReuse()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let model = _dataPages?[indexPath.row] {
            // 加载图片
            DispatchQueue.global().async {
                _ = model.help?.coverImage
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: _pageWidth, height: _heightItem)
    }
}

/// 处理scrollView回调逻辑
extension PYViewPage: UIScrollViewDelegate, PYViewPageControlDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _dataPages?[indexOfPage].help?.pause()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollEnd()
        }
    }
    
    /// 指定decelerate位移
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 滑动结束时判断是否需要切换页面
        let pageWidth = _pageWidth
        let offsetXDelta = targetContentOffset.pointee.x - _offsetXForCurrentPage
        
        // 根据滑动力度这里可能一次跳过多页面；合理控制decelerate的距离与达到页面宽度比例关系，以便更好的UI翻页体验
        let pageOffset = Int(round(offsetXDelta / pageWidth))
        if pageOffset != 0 {
             targetContentOffset.pointee.x = CGFloat(indexOfPage + pageOffset) * (_pageWidth + _paddingH) - _paddingH
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollEnd()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

    }
    
    /// 滚动结束了处理弹性移动
    func scrollEnd() {
        guard let dataPages = _dataPages else {
            return
        }
        
        // 滑动结束时判断是否需要切换页面
        let lastPageOffsetX = _offsetXForCurrentPage
        let currentOffsetX = _colloectionView.contentOffset.x
        let pageWidth = _pageWidth
        let offsetXDelta = currentOffsetX - lastPageOffsetX
        
        // 排除特殊情况
        if indexOfPage == 0 && currentOffsetX < lastPageOffsetX {
            scrollToPage(false, shouldScroll: false)
            return
        }
        
        if indexOfPage == (dataPages.count-1) && currentOffsetX > lastPageOffsetX {
            scrollToPage(false, shouldScroll: false)
            return
        }
        
        // 超出半个页面才会跳转控制
        if abs(offsetXDelta) > pageWidth/2 {
            let pageOffset = Int(round(offsetXDelta / pageWidth))
            
            if pageOffset > 0 && indexOfPage == dataPages.count-1 {
                return
            }
            
            if pageOffset < 0 && indexOfPage == 0 {
                return
            }
            
            indexOfPage += pageOffset
            
            scrollToPage(true, shouldScroll: true)
            
        } else {
            scrollToPage(false, shouldScroll: true)
        }
    }
    
    fileprivate func scrollToPage(_ isPageChanged: Bool, shouldScroll: Bool, animation: Bool = true) {
        guard let dataPages = _dataPages else {
            return
        }
        
        if indexOfPage >= dataPages.count {
            indexOfPage = dataPages.count - 1
        }
        
        if indexOfPage < 0 {
            indexOfPage = 0
        }
        
        let item = dataPages[indexOfPage]
        
        if isPageChanged {
            self._delegate?.willScrollToPage(indexOfPage, item: item)
            _pageControl.jumpToIndex(indexOfPage)
        } else {
            item.help?.play()
        }
        
        var offset = _colloectionView.contentOffset
        offset.x = _offsetXForCurrentPage
        
        if animation {
            if shouldScroll {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self._colloectionView.contentOffset = offset
                }) { (finished) in
                    if finished && isPageChanged {
                        self._delegate?.didScrollToPage(self.indexOfPage, item: item)
                        // 自动播放
                        item.help?.play()
                    }
                }
            } else if isPageChanged {
                self._delegate?.didScrollToPage(self.indexOfPage, item: item)
                // 自动播放
                item.help?.play()
            }
            
        } else {
            if shouldScroll {
                self._colloectionView.contentOffset = offset
            }
            
            if isPageChanged {
                self._delegate?.didScrollToPage(self.indexOfPage, item: item)
                // 自动播放
                item.help?.play()
            }
        }
    }
    
    func pageControlDidChangeToPage(_ index: Int) {
        if indexOfPage == index { return }
        
        _dataPages?[indexOfPage].help?.pause()
        indexOfPage = index
        scrollToPage(true, shouldScroll: true)
    }
}

