//
//  BEModelProvider.h
//  BytedEffects
//
//  Created by QunZhang on 2020/1/10.
//  Copyright © 2020 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEButtonItemModel.h"

@interface BEModelProvider : NSObject

@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *defaultValue;

- (NSArray<BEButtonItemModel *> *)buttonItemArrayWithDefaultIntensity;
- (NSArray<BEButtonItemModel *> *)buttonItemArray:(BEEffectNode)type;

@end
