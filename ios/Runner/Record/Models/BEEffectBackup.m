//
//  BEEffectBackup.m
//  BytedEffects
//
//  Created by QunZhang on 2020/1/7.
//  Copyright © 2020 ailab. All rights reserved.
//

#import "BEEffectBackup.h"

@interface BEEffectBackup ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *selectedNodeofPage;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectedNodeSet;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, BEButtonItemModel *> *buttonItemModelCache;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *buttonItemModelWithIntensity;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *savedIntensities;
@property (nonatomic, strong) NSString *filterPath;
@property (nonatomic, assign) CGFloat filterIntensity;
@property (nonatomic, assign) BEEffectNode currentSelectItem;

@end

@implementation BEEffectBackup

- (void)backup:(BEEffectNode *)currentSelectItem selectedNodeOfPage:(NSMutableDictionary<NSNumber *, NSNumber *> * __strong *)selectNodeOfPage selectedNodeSet:(NSMutableSet<NSNumber *> * __strong *)selectedNodeSet buttonItemModelCache:(NSMutableDictionary<NSNumber *, BEButtonItemModel *> * __strong *)buttonItemModelCache buttonItemModelWithIntensity:(NSMutableSet<NSNumber *> * __strong *)buttonItemModelWithIntensity savedIntensities:(NSDictionary<NSNumber *, NSNumber *> * __strong *)savedIntensities filterPath:(NSString * __strong *)filterPath filterIntensity:(CGFloat *)filterIntensity {
    _currentSelectItem = *currentSelectItem;
    _selectedNodeofPage = [*selectNodeOfPage mutableCopy];
    _selectedNodeSet = [*selectedNodeSet mutableCopy];
    _buttonItemModelCache = [*buttonItemModelCache mutableCopy];
    _buttonItemModelWithIntensity = [*buttonItemModelWithIntensity mutableCopy];
    _savedIntensities = [*savedIntensities mutableCopy];
    _filterPath = *filterPath;
    _filterIntensity = *filterIntensity;
    _available = YES;
    
    *currentSelectItem = BETypeClose;
    [*selectNodeOfPage removeAllObjects];
    [*selectedNodeSet removeAllObjects];
    [*buttonItemModelCache removeAllObjects];
    [*buttonItemModelWithIntensity removeAllObjects];
    *filterPath = nil;
    *filterIntensity = 0;
}

- (void)recover:(BEEffectNode *)currentSelectItem selectedNodeOfPage:(NSMutableDictionary<NSNumber *, NSNumber *> * __strong *)selectNodeOfPage selectedNodeSet:(NSMutableSet<NSNumber *> * __strong *)selectedNodeSet buttonItemModelCache:(NSMutableDictionary<NSNumber *, BEButtonItemModel *> * __strong *)buttonItemModelCache buttonItemModelWithIntensity:(NSMutableSet<NSNumber *> * __strong *)buttonItemModelWithIntensity savedIntensities:(NSDictionary<NSNumber *, NSNumber *> * __strong *)savedIntensities filterPath:(NSString * __strong *)filterPath filterIntensity:(CGFloat *)filterIntensity {
    *currentSelectItem = _currentSelectItem;
    *selectNodeOfPage = _selectedNodeofPage;
    *selectedNodeSet = _selectedNodeSet;
    *buttonItemModelCache = _buttonItemModelCache;
    *buttonItemModelWithIntensity = _buttonItemModelWithIntensity;
    *savedIntensities = _savedIntensities;
    *filterPath = _filterPath;
    *filterIntensity = _filterIntensity;
    _available = NO;
}

@end
