//
//  PhotoHandler.swift
//  JingChengDiningHall
//
//  Created by zhangxu on 2017/1/21.
//  Copyright © 2017年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class PhotoHandler: NSObject {
    
    // 单粒
    static let shared: PhotoHandler = PhotoHandler();
    
    // 初始化
    private override init() {
        super.init();
        
    }
    
    // 缩略图
    func thumbnailsCutfullPhoto(photo: UIImage) -> UIImage? {
        
        var newSize: CGSize = .zero;
        
        if photo.size.width/photo.size.height < 1 {
            newSize.width = photo.size.width;
            newSize.height = photo.size.width * 1;
        } else {
            newSize.height = photo.size.height;
            newSize.width = photo.size.height * 1;
        }
        
        
        UIGraphicsBeginImageContext(newSize);
        
        photo.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    }
    
    /**
     获取具体的图片
     
     @param asset         PHAsset 对象
     @param originalImage 是否是原图(YES为原图. NO 为缩略图.默认我 NO)
     @param completion     成功的回调
     
     @return 唯一地标识一个可删除的异步请求
     */
    func getPhotosWithAsset(asset: PHAsset, targetSize: CGSize, isOriginalImage: Bool, completion: @escaping(_ image: UIImage) -> ()) -> PHImageRequestID {
        
        var size: CGSize?;
        
        if isOriginalImage == true {
            size = PHImageManagerMaximumSize;
        } else {
            size = targetSize;
        }
        
        let options = PHImageRequestOptions();
        options.resizeMode = .fast;
        
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: size!, contentMode: .aspectFill, options: options, resultHandler: {
            (image, info) in
            
            guard let info = info as? [String: Any] else {
                return;
            }
            print(info);
            let downloadFinished: Bool? = ((info[PHImageCancelledKey] as? NSNumber)?.boolValue == nil && info[PHImageErrorKey] == nil);
            
            if downloadFinished != nil && image != nil {
                if isOriginalImage == false {
                    
                    let newImage = self.thumbnailsCutfullPhoto(photo: image!);
                    
                    completion(newImage!);
                } else {
                    
                    completion(image!);
                }
            }
        })
        return imageRequestID;
    }

}
