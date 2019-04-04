//
//  PYViewPageControl.swift
//  PYViewPaging
//
//  Created by Bob Lee on 2019/3/30.
//  Copyright © 2019 Bob Lee. All rights reserved.
//

import UIKit

protocol PYViewPageControlDelegate: NSObjectProtocol {
    func pageControlDidChangeToPage(_ index: Int)
}

/**
 实现分页索引提示效果
 能力：
 1.实现基础的索引指定逻辑
 2.支持索引切换效果自定义
 3.点击有效区域切换页面
 */
class PYViewPageControl: UIView, UIGestureRecognizerDelegate {
    
    private let _heightDot: CGFloat = 5
    weak var delegate: PYViewPageControlDelegate?
    private var _numberOfPage: Int = 0
    private var _indexOfPage: Int = 0
    private var _arrViews: [UIView] = []
    private var _currentDot: UIView? {
        return self.viewWithTag(1000+_indexOfPage)
    }
    
    init(_ delegate: PYViewPageControlDelegate) {
        super.init(frame: CGRect.init())
        self.delegate = delegate
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTapGuesture(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        for view in _arrViews {
            view.removeFromSuperview()
        }
        
        _arrViews.removeAll()
        
        // 计算位置
        var offsetX: CGFloat = 0 // 奇数页居中
        if _numberOfPage % 2 == 0 {
            offsetX = _heightDot/2
        }
        
        let span = Int((CGFloat(_numberOfPage) / 2).rounded(.up))
        var offsetXMax = -CGFloat(span-1) * _heightDot * CGFloat(2.0) - offsetX
        
        for i in 0..<_numberOfPage {
            let dot = UIView.init()
            dot.backgroundColor = UIColor.lightGray
            dot.tag = 1000+i
            dot.layer.cornerRadius = _heightDot/2
            addSubview(dot)
            _arrViews.append(dot)
            
            dot.snp.makeConstraints { (make) in
                make.width.height.equalTo(_heightDot)
                make.bottom.equalToSuperview().offset(-_heightDot*5)
                make.centerX.equalToSuperview().offset(offsetXMax)
            }
            
            offsetXMax += _heightDot * 2
        }
        
        animationDot(_currentDot, isSelected: true)
    }
    
    func setupData(_ numberOfPage: Int) {
        if _numberOfPage == numberOfPage { return }
        
        _numberOfPage = numberOfPage
        _indexOfPage = 0
        
        setupUI()
    }
    
    func jumpToIndex(_ index: Int) {
        guard let curDot = _currentDot else {
            return
        }
        
        if index == _indexOfPage || index >= _numberOfPage { return }
        
        _indexOfPage = index
        if let nextDot = _currentDot {
            animationDot(curDot, isSelected: false)
            animationDot(nextDot, isSelected: true)
        }
    }
    
    /// 实现滑动动画用
    func willJumpToIndex(_ offsetRatio: CGFloat) {
        if let curDot = _currentDot {
            curDot.snp.updateConstraints({ (make) in
                make.height.equalTo(_heightDot * (2 - abs(offsetRatio)))
            })
            
            let indexOffset = offsetRatio > 0 ? 1 : -1
            
            if let nextDot = self.viewWithTag(1000 + _indexOfPage + indexOffset) {
                nextDot.snp.updateConstraints({ (make) in
                    make.height.equalTo(_heightDot * (1 + abs(offsetRatio)))
                })
            }
            
            setNeedsLayout()
        }
    }
    
    private func animationDot(_ dot:UIView?, isSelected: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn, animations: {
            dot?.snp.updateConstraints({ (make) in
                make.height.equalTo(isSelected ? self._heightDot * 2 : self._heightDot)
            })
            dot?.backgroundColor = isSelected ? UIColor.gray : UIColor.lightGray
        }, completion: nil)
    }
    
    @objc private func handleTapGuesture(_ sender: UITapGestureRecognizer) {
        let _ = checkGuesture(sender, isTap: true)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return checkGuesture(gestureRecognizer, isTap: false)
    }
    
    /// 没有再子控件区域内不响应
    private func checkGuesture(_ sender: UIGestureRecognizer, isTap: Bool) -> Bool {
        let offset: CGFloat = 40
        if let dotMin = self.viewWithTag(1000), let dotMax = self.viewWithTag(1000 + _numberOfPage - 1) {
            let minX = dotMin.frame.minX - offset
            let maxX = dotMax.frame.maxX + offset
            
            let zone = CGRect.init(x: minX, y: 0, width: maxX-minX, height: frame.height)
            let point = sender.location(in: self)
            
            if zone.contains(point) {
                if isTap {
                    if point.x > (minX + (maxX - minX)/2) {
                        if _indexOfPage < (_numberOfPage - 1) {
                            self.delegate?.pageControlDidChangeToPage(_indexOfPage+1)
                        }
                    } else {
                        if _indexOfPage > 0 {
                            self.delegate?.pageControlDidChangeToPage(_indexOfPage-1)
                        }
                    }
                }
                return true
            }
        }
        
        return false
    }
    
}
