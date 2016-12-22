
//
//  Header.swift
//  CustomAlbum
//
//  Created by zhangxu on 2016/12/15.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit

let SCREEN_WIDRH = UIScreen.main.bounds.size.width;
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height;
let scale = UIScreen.main.scale;

// RGB 
func RGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    
    let color = UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1);
    return color;
}

func realValue(value: CGFloat) -> CGFloat {
    
    let newValue = value/375 * SCREEN_WIDRH;
    return newValue;
}
