//
//  BEGlobalData.m
//  BytedEffects
//
//  Created by QunZhang on 2019/11/17.
//  Copyright © 2019 ailab. All rights reserved.
//

#import "BEGlobalData.h"

static BOOL animojiEnable = NO;

@implementation BEGlobalData

+ (void)setAnimojiEnable:(BOOL)enable {
    animojiEnable = enable;
}

+ (BOOL)animojiEnable {
    return animojiEnable;
}

@end
