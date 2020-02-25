//
//  BEFaceBeautyViewController.h
//  BytedEffects
//
//  Created by QunZhang on 2019/8/19.
//  Copyright © 2019 ailab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BECloseableProtocol.h"
#import "BEButtonItemModel.h"
#import "BEModelProvider.h"

@interface BEFaceBeautyViewController : UIViewController <BECloseableProtocol>

- (instancetype)initWithType:(BEEffectNode)type modelProvider:(BEModelProvider *)provider;

- (void)setType:(BEEffectNode)node modelProvider:(BEModelProvider *)provider;;

- (void)setSelectNode:(BEEffectNode)node;

@end
