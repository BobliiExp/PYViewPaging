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
        viewPage = PYViewPage.init(self, heightItem: 285+150)
        view.addSubview(viewPage)
        
        viewPage.snp.makeConstraints { (make) in
            make.left.bottom.right.top.equalToSuperview()
        }
    }
    
    func setupData() {
        var pages: [FXConfigCellModel] = []
        var cell = FXConfigCellModel.init()
        cell.help = FXConfigHelpModel.init()
        cell.help?.coverPath = Bundle.main.path(forResource: "img1", ofType: "jpg")
        cell.help?.title = "video1"
        cell.help?.sourcePath = Bundle.main.path(forResource: cell.help?.title, ofType: ".m4v")
        cell.help?.desc = cell.help?.sourcePath
        pages.append(cell)
        
        cell = FXConfigCellModel.init()
        cell.help = FXConfigHelpModel.init()
        cell.help?.title = "video2"
        cell.help?.sourcePath = Bundle.main.path(forResource: cell.help?.title, ofType: ".m4v")
        cell.help?.desc = cell.help?.sourcePath
        pages.append(cell)
        
        cell = FXConfigCellModel.init()
        cell.help = FXConfigHelpModel.init()
        cell.help?.coverPath = Bundle.main.path(forResource: "img2", ofType: "jpg")
        cell.help?.title = "video3"
        cell.help?.sourcePath = Bundle.main.path(forResource: cell.help?.title, ofType: ".mp4")
        cell.help?.desc = cell.help?.sourcePath
        pages.append(cell)
        
        cell = FXConfigCellModel.init()
        cell.help = FXConfigHelpModel.init()
        cell.help?.coverPath = Bundle.main.path(forResource: "img3", ofType: "jpg")
        cell.help?.title = "video4"
        cell.help?.sourcePath = Bundle.main.path(forResource: cell.help?.title, ofType: ".mp4")
        cell.help?.desc = cell.help?.sourcePath
        pages.append(cell)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
            self.viewPage.setupData(pages)
        }
    }

}

extension ViewController: PYViewPageDelegate {
    func willScrollToPage(_ index: Int, item: FXConfigCellModel) {
        
    }
    
    func didScrollToPage(_ index: Int, item: FXConfigCellModel) {
        
    }
    
    func pageDidScroll(_ offsetRatio: CGFloat) {
        
    }
    
    func pageDidSelected(_ index: Int, item: FXConfigCellModel) {
        
    }
    
    
}

