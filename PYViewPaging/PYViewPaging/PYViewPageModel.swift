//
//  PYViewPageModel.swift
//  PYViewPaging
//
//  Created by Bob Lee on 2019/3/30.
//  Copyright © 2019 Bob Lee. All rights reserved.
//

import UIKit
import AVFoundation

/** 菜单cell数据模型 */
class FXConfigCellModel: NSObject {
    /** 功能标识FX_SKIN_SKINCOLOR（查角标样式用）；默认图标名称 */
    var FID: String = ""
    /** 功能icon */
    var iconPath: String?
    var iconPath_sel: String?
    /** 功能标题 */
    var name: String = "unknown"
    fileprivate var shouldCoverSlider: Bool = true
    fileprivate var shouldCoverToolbar: Bool = true
    /** 缓存slider等组件的变化值，便于UI使用（如果是数字+标题,数字默认值） */
    var defultValue: NSInteger = 0
    /** 功能是否可用，不可用时在release下不展示 */
    var isEnable: Bool = true
    /** 排列的顺序，这个必须配置，没有配置就放到最后 */
    var dispOrder: Int = 999
    
    //功能图标+标题样式id 有json对应
    fileprivate var _cellStyleId: String?
    var cellStyleId: String {
        if let sid = _cellStyleId { return sid }
        return "styleNormal"
    }
    
    // 如果是素材列表，素材的地址
    var resourcePath: String?
    
    //子模块json地址
    var subModuleJsonPath: String?
    
    //扩展项选中与否，默认未选中
    private var _isDefSel: Bool = false
    var isSelected: Bool = false
    fileprivate var isHome: Bool = false
    /** 仅供自由裁剪时携带UI变化用 */
    var isClipRatioChanged: Bool = false
    /** 是否已经修改过 */
    private var _hasModified: Bool = false
    private var _modifiedManual: Bool?
    var help: FXConfigHelpModel?
    
    weak var pageCell: PYViewPageCell?
    
    override init() {
        super.init()
        
        help = FXConfigHelpModel.init()
    }
}

/**
 帮助资源类型
 */
enum FXConfigHelpSourceType: Int8 {
    /** 静态图片 */
    case image = 0
    /** 视频MP4 */
    case video
    /** gif序列图 */
    case gif
    /** 图片序列 */
    case frame_animation
}

/**
 注意资源加载统一采用Data处理，且不做内存缓存支持
 */
class FXConfigHelpModel: NSObject {
    /** 对应的功能项ID */
    var configID: String?
    /** 资源路径 */
    var sourcePath: String?
    /** 视频封面图片，没有则找视频第一帧 */
    var coverPath: String?
    /** 视频默认展示的帧在视频中的时间点，或者帧序列图像默认展示的图像帧索引 */
    private var sourceTime: CMTimeValue = 0
    /** 媒体类型 */
    var sourceType: FXConfigHelpSourceType = .video
    /** 是否自动播放 */
    var isAutoPlay: Bool = false
    /** 功能描述 */
    var desc: String?
    var title: String?
    
    // MARK: - 视频相关
    
    lazy var asset: AVAsset? = {
        guard let path = sourcePath else { return nil }
        return AVAsset.init(url: URL.init(fileURLWithPath: path))
    }()
    
    lazy var playerItem: AVPlayerItem? = {
        guard let ass = asset else { return nil }
        return AVPlayerItem.init(asset: ass)
    }()
    
    private var _image: UIImage?
    var coverImage: UIImage? {
        set { _image = newValue }
        get {
            if let img = _image {
                return img
            }
            
            if let path = coverPath {
                do {
                    let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path), options: .uncached)
                    _image = UIImage.init(data: data)
                    return _image
                    
                } catch {}
            }
            
            switch sourceType {
            case .image:
                if let path = sourcePath {
                    do {
                        let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path), options: .uncached)
                        _image = UIImage.init(data: data)
                    } catch {}
                }
                
            case .video:
                if let ass = asset {
                let generator = AVAssetImageGenerator.init(asset: ass)
                    generator.appliesPreferredTrackTransform = true
                    do {
                        _image = UIImage.init(cgImage: try generator.copyCGImage(at: CMTime.init(value: sourceTime * Int64(ass.duration.timescale), timescale: ass.duration.timescale), actualTime: nil))
                    } catch {}
                }
                
                // TODO:            case .frame_animation:
                
                
            default:
                break
            }
            
            return _image
        }
    }
    
    override init() {
        super.init()
        
        desc = " Could not load IOSurface for time string. Rendering locally instead."
    }
    
    func clean() {
        
    }
}
