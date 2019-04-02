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
    fileprivate var _timeStart: TimeInterval = 0

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
        _colloectionView.decelerationRate = .normal
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
        scrollToPage(true, animation: animation)
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
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: _pageWidth, height: _heightItem)
    }
}

/// 处理scrollView回调逻辑
extension PYViewPage: UIScrollViewDelegate, PYViewPageControlDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _timeStart = NSDate.init().timeIntervalSince1970
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollEnd()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 计算偏移值
        let offset = scrollView.contentOffset.x
        let delta = offset - _offsetXForCurrentPage
        _pageControl.willJumpToIndex(delta/_pageWidth)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    /// 滚动结束了处理弹性移动
    func scrollEnd() {
        guard let dataPages = _dataPages else {
            return
        }
        
        let deltaTime = NSDate.init().timeIntervalSince1970 - _timeStart
        
        // 滑动结束时判断是否需要切换页面
        let lastPageOffsetX = _offsetXForCurrentPage
        let currentOffsetX = _colloectionView.contentOffset.x
        let pageWidth = _pageWidth
        let offsetXDelta = currentOffsetX - lastPageOffsetX
        
        // 排除特殊情况
        if indexOfPage == 0 && currentOffsetX < lastPageOffsetX {
            scrollToPage(false)
            return
        }
        
        if indexOfPage == (dataPages.count-1) && currentOffsetX > lastPageOffsetX {
            scrollToPage(false)
            return
        }
        
        // 滑动速度检查
        let speed = abs(Double(offsetXDelta)/deltaTime)
        let isQuicklySwip =  speed > 300.0
        
        print(speed)
        
        // 超出半个页面才会跳转控制
        if abs(offsetXDelta) > pageWidth/2 {
            let pageOffset = Int((offsetXDelta / pageWidth).rounded( offsetXDelta > 0 ? .up : .down))
            indexOfPage += pageOffset
            scrollToPage(true)
            
        } else if isQuicklySwip {
            indexOfPage += offsetXDelta>0 ? 1 : -1
            scrollToPage(true)
        } else {
            scrollToPage(false)
        }
    }
    
    fileprivate func scrollToPage(_ isPageChanged: Bool, animation: Bool = true) {
        guard  let pages = _dataPages else {
            return
        }
        
        let item = pages[indexOfPage]
        
        if isPageChanged {
            self._delegate?.willScrollToPage(indexOfPage, item: item)
            _pageControl.jumpToIndex(indexOfPage)
        }
        
        var offset = _colloectionView.contentOffset
        let directLeft = offset.x > _offsetXForCurrentPage
        offset.x = _offsetXForCurrentPage
        
        if animation {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self._colloectionView.contentOffset = offset
                if !isPageChanged {
                    self._pageControl.willJumpToIndex(directLeft ? 0.001 : -0.001)
                }
            }) { (finished) in
                if finished && isPageChanged {
                    self._delegate?.didScrollToPage(self.indexOfPage, item: item)
                }
            }
        } else {
            _colloectionView.contentOffset = offset
            if isPageChanged {
                _delegate?.didScrollToPage(indexOfPage, item: item)
            } else {
                _pageControl.willJumpToIndex(0)
            }
        }
    }
    
    func pageControlDidChangeToPage(_ index: Int) {
        indexOfPage = index
        scrollToPage(true)
    }
}

