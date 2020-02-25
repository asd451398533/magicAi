//
//  BEButtonItemModel.m
//  BytedEffects
//
//  Created by QunZhang on 2019/8/19.
//  Copyright © 2019 ailab. All rights reserved.
//

#import "BEButtonItemModel.h"

@interface BEButtonItemModel ()

@end

@implementation BEButtonItemModel


+ (instancetype)initWithID:(BEEffectNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc{
    BEButtonItemModel *model = [[self alloc] initWithSelectImg:selectImg unselectImg:unselectImg title:title desc:desc];
    model.ID = ID;
    return model;
}

+ (instancetype)initWithId:(BEEffectNode)ID {
    BEButtonItemModel *model = [[self alloc] initWithSelectImg:nil unselectImg:nil title:nil desc:nil];
    model.ID = ID;
    return model;
}

- (instancetype)initWithSelectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc {
    if (self = [super init]) {
        self.selectImg = selectImg;
        self.unselectImg = unselectImg;
        self.title = title;
        self.desc = desc;
    }
    return self;
}

#pragma mark - setter
- (void)setIntensity:(CGFloat)intensity {
    _intensity = intensity;
    if (_cell) {
        [_cell setPointOn:intensity > 0];
    }
}


@end
