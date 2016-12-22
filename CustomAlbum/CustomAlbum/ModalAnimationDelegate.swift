//
//  ModalAnimationDelegate.swift
//  仿微信照片弹出动画
//
//  Created by zhangxu on 2016/12/21.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit

class ModalAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // ⚠️ 一定要写成单粒,不然，下面的方法不会执行
    static let shared: ModalAnimationDelegate = ModalAnimationDelegate();
    
    private var isPresentAnimationing: Bool = true;
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentAnimationing = true;
        return self;
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentAnimationing = false;
        return self;
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresentAnimationing {
            presentViewAnimation(transitionContext: transitionContext);
        } else {
            dismissViewAnimation(transitionContext: transitionContext);
        }
    }
    
    // 弹出动画
    func presentViewAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        // 过渡view
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return;
        }
        
        // 容器view
        let containerView = transitionContext.containerView;
       
        
        // 过渡view添加到容器view上
        containerView.addSubview(toView);
        
        // 目标控制器
        guard let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PhotoDetailController else {
            return;
        }
        
        // indexPath
        guard let indexPath = toVc.indexPath else {
            return;
        }
        
        // 当前跳转的控制器
        guard let fromVc = ((transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UINavigationController)?.topViewController) as? PhotoListController else {
            return;
        };
        
        // 获取collectionView
        let collectionView = fromVc.collectionView;
        // 获取当前选中的cell
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
            return;
        }
        
        // 新建一个imageview添加到目标view之上,做为动画view
        let imageView = UIImageView();
        imageView.image = selectedCell.image;
        imageView.contentMode = .scaleAspectFit;
        imageView.clipsToBounds = true;
        
        
        // 获取window
        guard let window = UIApplication.shared.keyWindow else {
            return;
        }
        // 被选中的cell到目标view上的座标转换
        let originFrame = collectionView.convert(selectedCell.frame, to: window);
        imageView.frame = originFrame;
        
        // 将imageView 添加到容器视图上
        containerView.addSubview(imageView);
        
        let endFrame = window.bounds;
        
        toView.alpha = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            _ in
            imageView.frame = endFrame;
        }, completion: {
            _ in
            transitionContext.completeTransition(true);
            UIView.animate(withDuration: 0.2, animations: {
                _ in
                toView.alpha = 1;
            }, completion: {
                _ in
                imageView.removeFromSuperview();
            });
        })
    }
    
    // 消失动画
    func dismissViewAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        let transitionView = transitionContext.view(forKey: UITransitionContextViewKey.from);
        let contentView = transitionContext.containerView;
        // 取出modal出的来控制器
        guard let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? PhotoDetailController else {
            return;
        }
        
        // 取出当前显示的collectionview
        let collectionView = fromVc.collectionView;
        // 取出控制器当前显示的cell
        guard let dismissCell = collectionView.visibleCells.first as? PhotoDetailCell else {
            return;
        }
        // 新建过渡动画imageview
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.clipsToBounds = true;
        // 获取当前显示的cell 的image
        imageView.image = dismissCell.icon.image;
        // 获取当前显示cell在window中的frame
        imageView.frame = dismissCell.icon.frame;
        contentView.addSubview(imageView);
        // 动画最后停止的frame
        guard let indexPath = collectionView.indexPath(for: dismissCell) else {
            return;
        }
        // 取出要返回的控制器
        guard let toVC = ((transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UINavigationController)?.topViewController) as? PhotoListController else {
            return;
        }
        
        let originView = toVC.collectionView;
        guard let originCell = originView.cellForItem(at: indexPath) as? PhotoCell else {
            originView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            return;
        }

        guard let window = UIApplication.shared.keyWindow else {
            return;
        }
        
        let originFrame = originView.convert(originCell.frame, to: window);
        
        // 执行动画
        UIView.animate(withDuration: 0.5, animations: {
            _ in
            imageView.frame = originFrame;
            transitionView?.alpha = 0;
        }, completion: {
            _ in
            imageView.removeFromSuperview();
            transitionContext.completeTransition(true);
        })
        
    }
}
