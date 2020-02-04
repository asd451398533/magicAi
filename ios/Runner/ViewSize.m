//
//  ViewSize.m
//  Menu
//
//  Created by LiynXu on 2016/10/15.
//  Copyright © 2016年 LiynXu. All rights reserved.
//

#import "ViewSize.h"

@implementation ViewSize

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

CGFloat ScreenWidth(){
    return [UIScreen mainScreen].bounds.size.width;
}
CGFloat ScreenHieght(){
    return [UIScreen mainScreen].bounds.size.height;
}
CGFloat ItemWidth(){
    return (ScreenWidth()-5)/4.0;
}
CGFloat ItemHieght(){
    return ItemWidth()/3.0*4.0;
}
@end
