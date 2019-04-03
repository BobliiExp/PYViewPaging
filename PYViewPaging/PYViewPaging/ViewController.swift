//
//  ViewController.swift
//  PYViewPaging
//
//  Created by Bob Lee on 2019/3/30.
//  Copyright © 2019 Bob Lee. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var viewPage: PYViewPage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.setupData()
    }
    
    func setupUI() {
        viewPage = PYViewPage.init(self, heightItem: PYViewPageCell.heightPlayer+PYViewPageCell.heightRemain)
        view.addSubview(viewPage)
        
        viewPage.snp.makeConstraints { (make) in
            make.left.bottom.right.top.equalToSuperview()
        }
    }
    
    func setupData() {
        viewPage.isLoopPlay = true
        
        var pages: [FXConfigHelpModel] = []
        
        var help = FXConfigHelpModel.init()
        help.coverPath = Bundle.main.path(forResource: "img1", ofType: "jpg")
        help.title = "video1"
        help.configID = help.title
        help.sourcePath = Bundle.main.path(forResource: help.title, ofType: ".m4v")
        help.desc = help.sourcePath
        help.isLoopPlay = viewPage.isLoopPlay
        pages.append(help)
        
        help = FXConfigHelpModel.init()
        help.title = "video2"
        help.configID = help.title
        help.sourcePath = Bundle.main.path(forResource: help.title, ofType: ".m4v")
        help.desc = help.sourcePath
        help.isLoopPlay = viewPage.isLoopPlay
        pages.append(help)
        
        help = FXConfigHelpModel.init()
        help.coverPath = Bundle.main.path(forResource: "img2", ofType: "jpg")
        help.title = "video3"
        help.configID = help.title
        help.sourcePath = Bundle.main.path(forResource: help.title, ofType: ".mp4")
        help.desc = help.sourcePath
        help.isLoopPlay = viewPage.isLoopPlay
        pages.append(help)
        
        help = FXConfigHelpModel.init()
        help.coverPath = Bundle.main.path(forResource: "img3", ofType: "jpg")
        help.title = "video4"
        help.configID = help.title
        help.sourcePath = Bundle.main.path(forResource: help.title, ofType: ".mp4")
        help.desc = help.sourcePath
        pages.append(help)
        
        self.viewPage.setupData(pages)
    }

}

extension ViewController: PYViewPageDelegate {
    func willScrollToPage(_ index: Int, item: FXConfigHelpModel) {
        
    }
    
    func didScrollToPage(_ index: Int, item: FXConfigHelpModel) {
        
    }
    
    func pageDidScroll(_ offsetRatio: CGFloat) {
        
    }
    
    func pageDidSelected(_ index: Int, item: FXConfigHelpModel) {
        
    }
    
    
}

