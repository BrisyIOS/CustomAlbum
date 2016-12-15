//
//  PopAnimation.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/15.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit

class PopAnimation: NSObject, UIViewControllerAnimatedTransitioning {

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
        
    }
    
}
