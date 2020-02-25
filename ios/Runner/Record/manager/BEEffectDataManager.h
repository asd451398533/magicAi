// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEEffectResponseModel.h"
#import "BEButtonItemModel.h"
#import "BEComposerNodeModel.h"

//typedef NS_ENUM(NSUInteger, BEEffectDataManagerType) {
//    BEEffectDataManagerTypeSticker,
//    BEEffectDataManagerTypeFilter,
//    BEEffectDataManagerTypeAnimoji,
//    BEEffectDataManagerTypeArscan,
////    BEEffectDataManagerTypeBeauty,
////    BEEffectDataManagerTypeMakeup,
//};

typedef void(^BEEffectDataFetchCompletion)(BEEffectResponseModel * responseModel, NSError *error);

@interface BEEffectDataManager : NSObject

@property (nonatomic, readonly) BEEffectResponseModel *responseModel;

+ (instancetype)dataManagerWithType:(BEEffectNode)type;

+ (NSArray<BEEffectCategoryModel *> *)effectCategoryModelArray;

- (void)fetchDataWithCompletion:(BEEffectDataFetchCompletion)completion;

+ (NSArray <BEButtonItemModel *> *)buttonItemArray:(BEEffectNode)type;

+ (NSDictionary *)composerNodeDic;

+ (NSDictionary<NSNumber *, NSNumber *> *)defaultValue;

@end
