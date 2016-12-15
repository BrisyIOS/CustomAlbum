//
//  PhotoDetailCell.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/15.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailCell: UICollectionViewCell {
    
    var asset: PHAsset? {
        didSet {
            // 获取可选类型中的数据
            guard let asset = asset else {
                return;
            }
            
            let options = PHImageRequestOptions();
            options.isSynchronous = false;
            options.isNetworkAccessAllowed = true;
            let targetSize = CGSize(width: SCREEN_WIDRH, height: SCREEN_HEIGHT - CGFloat(64));
            PHCachingImageManager().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: {
                (image, _) in
                
                if let image = image {
                    self.icon.image = image;
                }
            })
        }
    };
    
    private lazy var icon: UIImageView = {
        let icon = UIImageView();
        return icon;
    }();
    
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        // 添加icon
        contentView.addSubview(icon);
    }
    
    // 设置子控件的frame
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let width = bounds.size.width;
        let height = bounds.size.height;
        
        if let asset = asset {
            let imageW = CGFloat(asset.pixelWidth);
            let imageH = CGFloat(asset.pixelHeight);
            let ratioW = imageW/width;
            let ratioH = imageH/height;
            
            
            // 设置ion的frame
            icon.center = CGPoint(x: width/2, y: height/2);
            var iconH = height;
            var iconW = imageW/ratioH;
            
            if imageW > width {
                iconW = width;
                iconH = imageH/ratioW;
            }
            
            icon.bounds = CGRect(x: 0, y: 0, width: iconW, height: iconH);
            
        }
        
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
