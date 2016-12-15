##demo名称
* CustomAlbum
</br></br>

##运行环境
* iOS 8.0+ / Mac OS X 10.11+ 
* Xcode 8.0+ 
* Swift 3.0+ 
</br></br>

##自定义系统相册
* 判断权限
* 获取相册列表
* 获取相册中图片

</br></br>
##获取相册列表
###定义一个相册模型 AlbumModel
<pre>
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
</pre>

</br></br>
###创建一个类AlbumController  用来展示相册列表
<pre>
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
tableView.rowHeight = 80;
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
</pre>


###创建 AlbumCell 

<pre>
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

</pre>

</br></br>


##获取照片列表
###创建PhotoListController
<pre>
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
func loadPhotoList() -> Void {

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
func loadImageArray() -> Void {

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

</pre>

###创建PhotoCell

<pre>

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

</pre>


</br></br>

##照片详情
###创建PhotoDetailController
<pre>
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

</pre>

</br></br>

###创建PhotoDetailCell

<pre>
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

</pre>

</br></br>

##点开照片详情的Push 动画
###创建PushAnimation

<pre>
import UIKit

class PushAnimation: NSObject,UIViewControllerAnimatedTransitioning {

var transitionContextT:UIViewControllerContextTransitioning?

// 动画执行时间
func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
return 0.3
}

// 执行动画
func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

self.transitionContextT = transitionContext

guard let toView = transitionContext.view(forKey: .to) else {
return;
}

guard let fromView = transitionContext.view(forKey: .from) else {
return;
}

//不添加的话，屏幕什么都没有
let containerView = transitionContext.containerView
containerView.addSubview(toView);
containerView.addSubview(fromView)

transitionContext.completeTransition(true);

// 修改frame
toView.frame = CGRect(x: 0, y: 64, width: SCREEN_WIDRH, height: SCREEN_HEIGHT - 64);

// 添加动画
startAnimation(targetView: toView);

}

// 开启动画
func startAnimation(targetView: UIView) -> Void {

targetView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3);
targetView.alpha = 0;


UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
_ in

targetView.transform = CGAffineTransform(scaleX: 1, y: 1);
targetView.alpha = 1;

}, completion: {
_ in

});
}

}
</pre>


##关于作者
* Edit by [张旭](https://github.com/BrisyIOS)



