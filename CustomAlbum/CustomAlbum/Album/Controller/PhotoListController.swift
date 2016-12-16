//
//  PhotoListController.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

let SCREEN_WIDRH = UIScreen.main.bounds.size.width;
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height;
let ITEM_SIZE = CGSize(width: 100, height: 100);
let MARGIN: CGFloat = 2;

class PhotoListController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    private let photoCellIdentifier = "photoCellIdentifier";
    
    // collectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout();
        layout.itemSize = ITEM_SIZE;
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2;
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

        
        // 添加collectionView
        view.addSubview(collectionView);
        
        // 注册cell
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier);
        
    
        // 加载assets数组
        loadPhotoList();
        
        // 异步加载缩略图
        let options = PHImageRequestOptions();
        options.isSynchronous = false;
        options.resizeMode = .fast;
        options.isNetworkAccessAllowed = true;
        
        
        let _ = self.assets!.map({
            (asset) in
            
            self.imageManager.requestImage(for: asset, targetSize: ITEM_SIZE, contentMode: .aspectFill, options: options, resultHandler: {
                (image, _) in
                if let image = image {
                    self.imageArray.append(image);
                }
                
            });
            
        });
        
        
        
        // 加载图片数组
        loadImageArray();
        

        // Do any additional setup after loading the view.
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
    
    // 加载图片数组
    private func loadImageArray() -> Void {
        
        let newOptions = PHImageRequestOptions();
        newOptions.isSynchronous = true;
        newOptions.resizeMode = .exact;
        newOptions.isNetworkAccessAllowed = true;
        
        DispatchQueue.global().async {
            _ in
   
            // 同步加载高清图片
            DispatchQueue.main.async {
                _ in
                
                //  清空数组
                self.imageArray.removeAll();
                
                let _ = self.assets!.map({
                    (asset) in
                    
                    self.imageManager.requestImage(for: asset, targetSize: ITEM_SIZE, contentMode: .aspectFill, options: newOptions, resultHandler: {
                        (image, _) in
                        
                        if let image = image {
                            self.imageArray.append(image);
                        }
                    })
                });
                
                // 刷新数据
                self.collectionView.reloadData();
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
                cell?.image = imageArray[indexPath.row];
            }
        }
        return cell!;
    }

    // 选中cell ， 进入照片详情
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false);
        
        let photoDetailVc = PhotoDetailController();
        navigationController?.delegate = self;
   
        if let assets = assets {
            if indexPath.row < assets.count {
                
                photoDetailVc.assets = assets;
                photoDetailVc.indexPath = indexPath;
                navigationController?.pushViewController(photoDetailVc, animated: true);
                
            }
        }
    }
    
    // 实现代理方法
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            
            return PushAnimation();
        } else {
            return nil;
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
