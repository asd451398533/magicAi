//
//  BEModelProvider.m
//  BytedEffects
//
//  Created by QunZhang on 2020/1/10.
//  Copyright © 2020 ailab. All rights reserved.
//

#import "BEModelProvider.h"
#import "BEEffectDataManager.h"

@interface BEModelProvider ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray<BEButtonItemModel *> *> *data;

@end

@implementation BEModelProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<BEButtonItemModel *> *)buttonItemArray:(BEEffectNode)type {
    if ([self.data objectForKey:@(type)] == nil) {
        [self.data setObject:[BEEffectDataManager buttonItemArray:type] forKey:@(type)];
    }
    return [self.data objectForKey:@(type)];
}

- (NSArray<BEButtonItemModel *> *)buttonItemArrayWithDefaultIntensity {
    NSMutableArray<BEButtonItemModel *> *array = [NSMutableArray array];
    [array addObjectsFromArray:[self buttonItemArray:BETypeBeautyFace]];
    [array addObjectsFromArray:[self buttonItemArray:BETypeBeautyReshape]];
    
    for (BEButtonItemModel *model in array) {
        model.intensity = [[self.defaultValue objectForKey:@(model.ID)] floatValue];
    }
    return array;
}

#pragma mark - getter
- (NSDictionary<NSNumber *,NSNumber *> *)defaultValue {
    return BEEffectDataManager.defaultValue;
}

@end
