//
//  PYViewPageCell.swift
//  PYViewPaging
//
//  Created by Bob Lee on 2019/3/30.
//  Copyright © 2019 Bob Lee. All rights reserved.
//

import UIKit
import AVFoundation

class PYViewPageCell: UICollectionViewCell {
    /** 功能图标 */
    private var imgVIcon: UIImageView!
    /** 媒体 */
    private var player: PYViewPageMedia!
    private var labTitle: UILabel!
    private var labDesc: UILabel!
    
    weak var dataModel: FXConfigCellModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        player = PYViewPageMedia.init(frame: CGRect.init())
        contentView.addSubview(player)
        
//        imgVIcon = UIImageView.init(frame: CGRect.init())
//        imgVIcon.layer.cornerRadius = 8
//        imgVIcon.layer.borderWidth = 0.5
//        imgVIcon.layer.backgroundColor = UIColor.white.cgColor
//        imgVIcon.layer.borderColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5).cgColor
//        contentView.addSubview(imgVIcon)
        
        labTitle = UILabel.init(frame: CGRect.init())
        labTitle.font = UIFont.boldSystemFont(ofSize: 26)
        labTitle.textColor = UIColor.black
        contentView.addSubview(labTitle)
        
        labDesc = UILabel.init(frame: CGRect.init())
        labDesc.font = UIFont.systemFont(ofSize: 16)
        labDesc.textColor = UIColor.black
        // 处理top-left
        labDesc.numberOfLines = 0
        labDesc.sizeToFit()
        contentView.addSubview(labDesc)
        
        backgroundColor = .white
        // 自己的shadow
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5)
        layer.shadowOpacity = 0.25
        layer.borderColor = UIColor.gray.withAlphaComponent(0.15).cgColor
        layer.borderWidth = 0.5
        
        let marginIcon = 18
        let marginTxtH = 23
        let marginTxtV = 21
        let heightPlayer = 285
        let heightRemain = 150
        let widthIcon = 37
        let heightTitle = 32
        
        // layout
        player.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(heightPlayer)
        }
        
//        imgVIcon.snp.makeConstraints { (make) in
//            make.left.top.equalToSuperview().offset(marginIcon)
//            make.width.height.equalTo(widthIcon)
//        }
        
        labTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(marginTxtH)
            make.right.equalToSuperview().offset(-marginTxtH)
            make.top.equalTo(player.snp.bottom).offset(marginTxtV)
            make.height.equalTo(heightTitle)
        }
        
        labDesc.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(marginTxtH)
            make.right.equalToSuperview().offset(-marginTxtH)
            make.top.equalTo(labTitle.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-marginTxtV)
        }
    }
    
    func setupData(_ dataModel: FXConfigCellModel) {
        self.dataModel = dataModel
        
        if let model = dataModel.help {
            player.setupData(model)
            
            labDesc.text = model.desc
            labTitle.text = model.title
        }
    }
}

/**
 媒体集约处理
 */
class PYViewPageMedia: UIView, FXConfigHelpDelegate {
    weak var dataModel: FXConfigHelpModel?
    /** 图片默认是要展示的 */
    private var _imgV: UIImageView!
    /** 播放视频帧layer，播放器由数据提供不能重用因为playeritem不能关联多个播放器会崩溃*/
    private var _playerLayer: AVPlayerLayer?
    private var _isPlaying: Bool = false
//    private var _imgVAnimation : PYViewAnimation?
    private var _btnPlay: UIButton?
    private let cornerWidth: CGFloat = 20
    
    var isPlaying: Bool {
        return dataModel?.isPlaying ?? false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    deinit {
        dataModel?.pause()
        print("cell release")
        NotificationCenter.init().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if layer == self.layer {
            _playerLayer?.bounds = layer.bounds
            _playerLayer?.position = layer.position
            
            // custom mask
            if #available(iOS 11.0, *) {}
            else {
                if layer.mask == nil {
                    let path = UIBezierPath.init(roundedRect: layer.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize.init(width: cornerWidth, height: cornerWidth))
                    let mask = CAShapeLayer.init()
                    mask.path = path.cgPath
                    layer.mask = mask
                }
            }
        }
    }
    
    private func setupUI() {
        _imgV = UIImageView.init()
        _imgV.contentMode = .scaleAspectFill
        _imgV.clipsToBounds = true
        addSubview(_imgV)
        
        _imgV.snp.makeConstraints { (make) in
            make.left.bottom.top.right.equalToSuperview()
        }
        
        // 设置mask
        if #available(iOS 11.0, *) {
            layer.cornerRadius = cornerWidth
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            layer.masksToBounds = true
        }
    }
    
    func setupData(_ dataModel: FXConfigHelpModel) {
        self.dataModel = dataModel
        dataModel.delegate = self
        _imgV.image = dataModel.coverImage
        
        if dataModel.sourceType == .video {
            if _playerLayer == nil && dataModel.sourcePath != nil {
                _playerLayer = AVPlayerLayer.init()
                _playerLayer?.videoGravity = .resizeAspectFill
                _playerLayer?.masksToBounds = true
                layer.addSublayer(_playerLayer!)
                bringSubviewToFront(_imgV)
            }
            
            _playerLayer?.player = dataModel.videoPlayer
            
//            if _btnPlay == nil {
//                _btnPlay = UIButton.init(type: .custom)
//                _btnPlay?.setTitle("播放", for: .normal)
//                _btnPlay?.setTitle("暂停", for: .selected)
//                _btnPlay?.addTarget(self, action: #selector(btnPlayClicked(_:)), for: .touchUpInside)
//                addSubview(_btnPlay!)
//
//                _btnPlay?.snp.makeConstraints({ (make) in
//                    make.width.equalTo(100)
//                    make.height.equalTo(40)
//                    make.center.equalToSuperview()
//                })
//            }
        }
    }
    
    func videoStatusChanged(_ isPause: Bool, model: FXConfigHelpModel, cover: Bool) {
        if model == dataModel {
            if isPause {
                _btnPlay?.isSelected = false
                if cover { changeCover() }
            } else {
                _btnPlay?.isSelected = true
                if cover { changeCover(false) }
            }
        }
    }
    
    func play() {
        guard let model = dataModel else { return }
        if model.sourceType == .image { return }
        
        model.play()
    }
    
    func pause() {
        guard let model = dataModel else { return }
        if model.sourceType == .image { return }
        
        model.pause()
    }
    
    private func changeCover(_ isVisiable: Bool = true) {
        _imgV.isHidden = !isVisiable
        _btnPlay?.isHidden = !isVisiable
    }
    
    @objc private func btnPlayClicked(_ btn: UIButton) {
        if btn.isSelected {
            pause()
        } else {
            play()
        }
    }
}
