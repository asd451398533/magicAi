//
//  RectView.h
//  Runner
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef RectView_h
#define RectView_h

#import <UIKit/UIKit.h>

#endif /* RectView_h */
@interface RectView: UIView
    // 步骤3 提供模型
    @property (nonatomic, strong)RectView *model;
    - (void) drawRect:(CGRect*)rect;
@end
