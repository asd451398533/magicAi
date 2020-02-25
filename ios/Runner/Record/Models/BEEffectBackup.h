//
//  BEEffectBackup.h
//  BytedEffects
//
//  Created by QunZhang on 2020/1/7.
//  Copyright © 2020 ailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEButtonItemModel.h"

@interface BEEffectBackup : NSObject

@property (nonatomic, assign) BOOL available;

- (void)backup:(BEEffectNode *)currentSelectItem selectedNodeOfPage:(NSMutableDictionary<NSNumber *, NSNumber *> * __strong *)selectNodeOfPage selectedNodeSet:(NSMutableSet<NSNumber *> * __strong *)selectedNodeSet buttonItemModelCache:(NSMutableDictionary<NSNumber *, BEButtonItemModel *> * __strong *)buttonItemModelCache buttonItemModelWithIntensity:(NSMutableSet<NSNumber *> * __strong *)buttonItemModelWithIntensity savedIntensities:(NSDictionary<NSNumber *, NSNumber *> * __strong *)savedIntensities filterPath:(NSString * __strong *)filterPath filterIntensity:(CGFloat *)filterIntensity;

- (void)recover:(BEEffectNode *)currentSelectItem selectedNodeOfPage:(NSMutableDictionary<NSNumber *, NSNumber *> * __strong *)selectNodeOfPage selectedNodeSet:(NSMutableSet<NSNumber *> * __strong *)selectedNodeSet buttonItemModelCache:(NSMutableDictionary<NSNumber *, BEButtonItemModel *> * __strong *)buttonItemModelCache buttonItemModelWithIntensity:(NSMutableSet<NSNumber *> * __strong *)buttonItemModelWithIntensity savedIntensities:(NSDictionary<NSNumber *, NSNumber *> * __strong *)savedIntensities filterPath:(NSString * __strong *)filterPath filterIntensity:(CGFloat *)filterIntensity;

@end
