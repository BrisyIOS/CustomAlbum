//
//  AlbumController.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/14.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit
import Photos

class AlbumController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // cell标识
    private let albumCellIdentifier = "albumCellIdentifier";
    
    // tableView 
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain);
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = realValue(value: 80);
        tableView.tableFooterView = UIView();
        return tableView;
    }();
    
    // 相册数据
    private lazy var albums: [AlbumModel] = [AlbumModel]();

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏不透明
        navigationController?.navigationBar.isTranslucent = false;
        
        // 添加tableView
        view.addSubview(tableView);
        
        // 注册cell
        tableView.register(AlbumCell.self, forCellReuseIdentifier: albumCellIdentifier);
        
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                      subtype: .albumRegular,
                                                                      options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections
                as! PHFetchResult<PHAssetCollection>)
            
            //相册按包含的照片数量排序（降序）
            self.albums.sort { (album1, album2) -> Bool in
                return (album1.fetchResult?.count)! > (album2.fetchResult?.count)!
            }
            
            //异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
        
        

        // Do any additional setup after loading the view.
    }
    
    //转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        
        for i in 0..<collection.count{
            //获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            
            var assets = [PHAsset]();
            
            for i in 0..<assetsFetchResult.count {
                
                let asset = assetsFetchResult[i];
                assets.append(asset);
            }
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                albums.append(AlbumModel(title: c.localizedTitle,
                                         fetchResult: assets));
            }
        }
        
        // 将相册名转为中文
        let _ = albums.map({
            (album) in
            
            if album.title == "Recently Added" {
                album.title = "最近添加";
            } else if album.title == "Favorites" {
                album.title = "个人收藏";
            } else if album.title == "Recently Deleted" {
                album.title = "最近删除";
            } else if album.title == "Videos" {
                album.title = "视频";
            } else if album.title == "All Photos" {
                album.title = "所有照片";
            } else if album.title == "Selfies" {
                album.title = "自拍";
            } else if album.title == "Screenshots" {
                album.title = "屏幕快照";
            } else if album.title == "Camera Roll" {
                album.title = "相机胶卷";
            }
        });
        
    }
    
    // 返回表尾高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1;
    }
    
    // 返回行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count;
    }
    
    // 返回cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellIdentifier, for: indexPath) as? AlbumCell;
        if indexPath.row < albums.count {
            cell?.album = albums[indexPath.row];
        }
        return cell!;
    }
    
    // 选中cell, 查看相册列表
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
        
        let photoVc = PhotoListController();
        photoVc.assets = albums[indexPath.row].fetchResult;
        navigationController?.pushViewController(photoVc, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 设置子控件的frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        tableView.frame = view.bounds;
    }


}
