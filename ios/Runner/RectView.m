//
//  RectView.m
//  Runner
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RectView.h"

@interface RectView()
    
    @property (nonatomic,weak) UILabel *lable;
    
@end

@implementation RectView
    
    // 步骤 1：重写initWithFrame:方法，创建子控件并 - 添加
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
//        UILabel *lable = [[UILabel alloc] init];
//        self.lable = lable;
//        [self addSubview:lable];
    }
    return self;
}
    // 步骤 2：重写layoutSubviews，子控件设置frame
- (void)layoutSubviews {
    
    [super layoutSubviews];
//    CGSize size = self.frame.size;
//    self.lable.frame = CGRectMake(0, 0, size.width * 0.5, size.height * 0.5);
}
    // 步骤 4： 子控件赋值
- (void)setModel:(RectView *)model {
    
}
    
    - (void)drawRect:(CGRect)rect{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
            //画矩形
            CGContextAddRect(context, CGRectMake(20, 20, 100, 100));
        
            //图案渲染到画布上(空心只有线)
            CGContextStrokePath(context);
            //图案渲染到画布上(实线填充)
            CGContextFillPath(context);
    }
    /*
     绘制矩形
     */
//- (void) drawRect{
//    //获取上下文引用，类试canvas
//
//}
@end
