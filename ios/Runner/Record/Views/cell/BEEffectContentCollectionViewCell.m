// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEEffectContentCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIResponder+BEAdd.h"
#import "BEStudioConstants.h"
#import "BEFaceBeautyViewController.h"

@implementation BEEffectContentCollectionViewCellFactory

+ (Class)contentCollectionViewCellWithPanelTabType:(BEEffectPanelTabType)type {
    Class cellClass = [BEEffectContentCollectionViewCell class];
    switch (type) {
        case BEEffectPanelTabBeautyFace:
        case BEEffectPanelTabBeautyReshape:
        case BEEffectPanelTabBeautyBody:
            cellClass = [BEEffectFaceBeautyViewCell class];
            break;
        case BEEffectPanelTabMakeup:
            cellClass = [BEEffectMakeupCollectionViewCell class];
            break;
        case BEEffectPanelTabFilter:
            cellClass = [BEEffecFiltersCollectionViewCell class];
            break;

    }
    return cellClass;
}

@end

@interface BEEffectContentCollectionViewCell ()

- (void)displayContentController:(UIViewController *)viewController;

@end

@implementation BEEffectContentCollectionViewCell

- (void)displayContentController:(UIViewController *)viewController {
    UIViewController *parent = [self be_topViewController];
    [parent addChildViewController:viewController];
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:parent];
    [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)setCellUnSelected{
    return ;
}
@end

#pragma mark - 滤镜cell

#import "BEModernFilterPickerViewController.h"

@interface BEEffecFiltersCollectionViewCell ()

@property (nonatomic, strong) BEModernFilterPickerViewController *filterVC;

@end

@implementation BEEffecFiltersCollectionViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.filterVC = [BEModernFilterPickerViewController new];
    [self displayContentController:self.filterVC];
}

- (void)setCellUnSelected{
    [self.filterVC setAllCellsUnSelected];
}

- (void)setSelectItem:(NSString *)filterPath {
    [self.filterVC setSelectItem:filterPath];
}

@end

#pragma mark - general beauty cell

@interface BEEffectFaceBeautyViewCell ()

@property (nonatomic, strong) BEFaceBeautyViewController *beautyVC;

@end

@implementation BEEffectFaceBeautyViewCell

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self displayContentController:self.beautyVC];
}

- (void)onClose {
    [self.beautyVC onClose];
}


- (void) setCellUnSelected{
    [super setCellUnSelected];
    
    [self.beautyVC onClose];
}

- (void)setSelectNode:(BEEffectNode)node {
    [self.beautyVC setSelectNode:node];
}

#pragma mark - setter

- (void)setType:(BEEffectNode)type modelProvider:(BEModelProvider *)provider {
    _type = type;
    [self.beautyVC setType:type modelProvider:provider];
}

#pragma mark - getter
- (BEFaceBeautyViewController *)beautyVC {
    if (!_beautyVC) {
        _beautyVC = [BEFaceBeautyViewController new];
    }
    return _beautyVC;
}
@end


#pragma mark - makeup cell
@implementation BEEffectMakeupCollectionViewCell
@end
