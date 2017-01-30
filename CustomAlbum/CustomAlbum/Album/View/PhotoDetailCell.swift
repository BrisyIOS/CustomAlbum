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
           
            // 获取原图
            _ = PhotoHandler.shared.getPhotosWithAsset(asset: asset, targetSize: PHImageManagerMaximumSize, isOriginalImage: true, completion: { (image) in
                
                guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
                    return;
                }
                self.icon.image = UIImage.init(data: imageData);
                
            })
        }
    };
  
    
    lazy var icon: UIImageView = {
        let icon = UIImageView();
        icon.contentMode = .scaleAspectFit;
        icon.clipsToBounds = true;
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
  
        icon.frame = bounds;
  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
