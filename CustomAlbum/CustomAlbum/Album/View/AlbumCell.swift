//
//  AlbumCell.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    // 图片
    private lazy var icon: UIImageView = {
        let icon = UIImageView();
        icon.backgroundColor = UIColor.init(red: 241/255, green: 204/255, blue: 40/255, alpha: 1);
        return icon;
    }();
    
    // 相册名
    private lazy var nameLabel: UILabel = {
        let label = UILabel();
        label.font = UIFont.systemFont(ofSize: 15);
        label.textColor = UIColor.black;
        label.textAlignment = .left;
        return label;
    }();
    
 
    var album: AlbumModel? {
        didSet {
            // 获取可选类型中的数据
            guard let album = album else {
                return;
            }
            
            if let fetchResult = album.fetchResult, let title = album.title {
                nameLabel.text = "\(title) (\(fetchResult.count))";
                print(nameLabel.text ?? "");
            }
        }
    }
    
    // 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        // 添加相册图片
        contentView.addSubview(icon);
        
        // 添加相册名称
        contentView.addSubview(nameLabel);
        
    }
    
    // 设置子控件的frame
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let width = bounds.size.width;
        
        // 设置相册图片
        let iconX: CGFloat = 10;
        let iconY: CGFloat = 10;
        let iconW: CGFloat = 60;
        let iconH: CGFloat = iconW;
        icon.frame = CGRect(x: iconX, y: iconY, width: iconW, height: iconH);
        
        // 设置相册名称的frame
        let nameLabelX: CGFloat = icon.frame.maxX + 20;
        let nameLabelY: CGFloat = icon.frame.minY;
        let nameLabelW: CGFloat = width - nameLabelX * 2;
        let nameLabelH: CGFloat = iconH;
        nameLabel.frame = CGRect(x: nameLabelX, y: nameLabelY, width: nameLabelW, height: nameLabelH);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
