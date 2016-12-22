//
//  PhotoListController.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

let ITEM_SIZE = CGSize(width: realValue(value: 90), height: realValue(value: 100));
let IMAGE_SIZE = CGSize(width: realValue(value: 90 * 2) * scale, height: realValue(value: 90 * 2) * scale);
let MARGIN: CGFloat = realValue(value: 3);

class PhotoListController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let photoCellIdentifier = "photoCellIdentifier";
    
    // collectionView
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout();
        layout.itemSize = ITEM_SIZE;
        layout.minimumLineSpacing = realValue(value: MARGIN);
        layout.minimumInteritemSpacing = realValue(value: MARGIN);
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDRH, height: SCREEN_HEIGHT - CGFloat(64)), collectionViewLayout: layout);
        collectionView.backgroundColor = UIColor.clear;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.contentInset = UIEdgeInsets(top: MARGIN, left: MARGIN, bottom: MARGIN, right: MARGIN);
        return collectionView;
    }();
    
    /// 带缓存的图片管理对象
    private lazy var imageManager:PHCachingImageManager = PHCachingImageManager();
    
    // 单个相册中存储的图片数组
    var assets: [PHAsset]?;
    
    // 存放image的数据
    private lazy var imageArray: [UIImage] = [UIImage]();

    override func viewDidLoad() {
        super.viewDidLoad()

        print("-------\(IMAGE_SIZE)")
        // 添加collectionView
        view.addSubview(collectionView);
        
        // 注册cell
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier);
        
    
        // 加载assets数组
        loadPhotoList();
      
        // 缓存图片
        cachePhotos();
 

        // Do any additional setup after loading the view.
    }
    
    // 缓存照片
    func cachePhotos() -> Void {
        
        let newOptions = PHImageRequestOptions();
        newOptions.isSynchronous = false;
        newOptions.resizeMode = .exact;
        newOptions.isNetworkAccessAllowed = true;
        self.imageManager.startCachingImages(for: assets!, targetSize: IMAGE_SIZE, contentMode: .aspectFit, options: newOptions);
    }
    
    // 加载assets数组
    private func loadPhotoList() -> Void {
        
        if assets == nil {
            assets = [PHAsset]();
            //则获取所有资源
            let allPhotosOptions = PHFetchOptions()
            //按照创建时间倒序排列
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
            //只获取图片
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                     PHAssetMediaType.image.rawValue)
            let assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                     options: allPhotosOptions)
            for i in 0..<assetsFetchResults.count {
                let asset = assetsFetchResults[i];
                assets?.append(asset);
            }
        }
        
    }
 
    
    // 返回行数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assets?.count ?? 0
    }
    
    // 返回cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as? PhotoCell;
        if let assets = assets {
            
            if indexPath.row < assets.count {
                let options = PHImageRequestOptions();
                options.isSynchronous = true;
                options.resizeMode = .fast;
                options.isNetworkAccessAllowed = true;
                let asset = assets[indexPath.row];
                self.imageManager.requestImage(for: asset, targetSize: IMAGE_SIZE, contentMode: .aspectFit, options: options, resultHandler: {
                    (image, _) in
                    cell?.image = image;
                })
            }
        }
        return cell!;
    }

    // 选中cell ， 进入照片详情
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false);
        
        let photoDetailVc = PhotoDetailController();
   
        if let assets = assets {
            if indexPath.row < assets.count {
                
                photoDetailVc.assets = assets;
                photoDetailVc.indexPath = indexPath;
                photoDetailVc.transitioningDelegate = ModalAnimationDelegate.shared;
                photoDetailVc.modalPresentationStyle = .custom;
                present(photoDetailVc, animated: true, completion: nil);
                
            }
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
