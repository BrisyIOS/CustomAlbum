//
//  PhotoCell.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    
    // 图片
    private lazy var icon: UIImageView = {
        let icon = UIImageView();
        return icon;
    }();
    
    var image: UIImage? {
        didSet {
            guard let image = image else {
                return;
            }
            
            icon.image = image;
        }
    }
    
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        // 添加图片
        contentView.addSubview(icon);
    }
    
    // 设置子控件的frame
    override func layoutSubviews() {
        super.layoutSubviews();
        
        icon.frame = bounds;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
