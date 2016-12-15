//
//  PhotoDetailController.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/15.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // cell标识
    private let photoDetailCellIdentifier = "photoDetailCellIdentifier";
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout();
        layout.scrollDirection = .horizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSize(width: SCREEN_WIDRH, height: SCREEN_HEIGHT - CGFloat(64));
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDRH, height: SCREEN_HEIGHT - CGFloat(64)), collectionViewLayout: layout);
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = UIColor.clear;
        collectionView.isPagingEnabled = true;
        collectionView.showsHorizontalScrollIndicator = false;
        return collectionView;
    }();
    
    // 选中的索引
    var indexPath: IndexPath?;
    // assets 
    var assets: [PHAsset]?;
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(back));
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        // 设置颜色为黑色
        view.backgroundColor = UIColor.black;
        
        // 添加collectionView
        view.addSubview(collectionView);
        
        // 注册cell
        collectionView.register(PhotoDetailCell.self, forCellWithReuseIdentifier: photoDetailCellIdentifier);
        
        // 改变偏移量
        if let indexPath = indexPath {
            collectionView.scrollToItem(at: indexPath, at: .right, animated: false);
        }

        // Do any additional setup after loading the view.
    }
    
    func back() -> Void {
        
        self.navigationController!.popViewController(animated: false);
    }
    
    // 返回行
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let assets = assets {
            return assets.count;
        } else {
            return 0;
        }
    }

    
    // 返回cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoDetailCellIdentifier, for: indexPath) as? PhotoDetailCell;
        if let assets = assets {
            if indexPath.row < assets.count {
                cell?.asset = assets[indexPath.row];
            }
        }
        return cell!;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
