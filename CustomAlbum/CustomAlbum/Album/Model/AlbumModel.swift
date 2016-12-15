//
//  AlbumModel.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class AlbumModel: NSObject {
    
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult: [PHAsset]?;
    
    init(title:String?,fetchResult: [PHAsset]){
        self.title = title
        self.fetchResult = fetchResult
    }

}
