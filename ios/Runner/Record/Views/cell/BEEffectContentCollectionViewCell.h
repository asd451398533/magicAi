// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "UICollectionViewCell+BEAdd.h"
#import "BEEffectResponseModel.h"
#import "BECloseableProtocol.h"
#import "BEButtonItemModel.h"
#import "BEModelProvider.h"

@class BEEffectContentCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

@interface BEEffectContentCollectionViewCellFactory : NSObject

+ (Class)contentCollectionViewCellWithPanelTabType:(BEEffectPanelTabType)type;

@end

@interface BEEffectContentCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) BOOL shouldClearStatus;

-(void)setCellUnSelected;
@end

//@interface BEEffectFaceBeautyCollectionViewCell : BEEffectContentCollectionViewCell
//-(void)setCellUnSelected;
//@end

@interface BEEffecFiltersCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
- (void)setSelectItem:(NSString *)filterPath;
@end

//@interface BEEffectMakeupCollectionViewCell : BEEffectContentCollectionViewCell
//-(void)setCellUnSelected;
//@end

@interface BEEffectStickersCollectionViewCell : BEEffectContentCollectionViewCell
-(void)setCellUnSelected;
@end

@interface BEEffectFaceBeautyViewCell : BEEffectContentCollectionViewCell <BECloseableProtocol>

@property (nonatomic, assign, readonly) BEEffectNode type;

- (void) setCellUnSelected;
- (void)setSelectNode:(BEEffectNode)node;
- (void)setType:(BEEffectNode)type modelProvider:(BEModelProvider *)provider;

@end

@interface BEEffectMakeupCollectionViewCell : BEEffectFaceBeautyViewCell

@end

NS_ASSUME_NONNULL_END
