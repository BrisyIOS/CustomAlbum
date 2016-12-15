//
//  PushAnimation.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/15.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

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
