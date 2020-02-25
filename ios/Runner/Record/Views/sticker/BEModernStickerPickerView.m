// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#import "BEModernStickerPickerView.h"

#import <Masonry/Masonry.h>

#import "BEModernStickerCollectionViewCell.h"
#import "BEStudioConstants.h"
#import "BEEffectDataManager.h"

@interface BEModernStickerPickerView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSArray<BEEffectSticker*> *stickers;
@property (nonatomic, assign) NSInteger currentSelectItem;


@end

@implementation BEModernStickerPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        _enable = YES;
        
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.mas_equalTo(self).with.offset(5);
            make.leading.trailing.equalTo(self);
        }];
    }
    return self;
}

- (void)refreshWithStickers:(NSArray<BEEffectSticker *> *)stickers{
    self.stickers = stickers;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)refreshWithType:(BEEffectNode)type {
    self.type = type;
    BEEffectDataManager *manager = [BEEffectDataManager dataManagerWithType:type];
    [manager fetchDataWithCompletion:^(BEEffectResponseModel *responseModel, NSError *error) {
        [self refreshWithStickers:responseModel.stickerGroup.firstObject.stickers];
    }];
}

- (void)recoverState:(NSString *)path {
    self.currentSelectItem = 0;
    for (int i = 0; i < self.stickers.count; i++) {
        if ([self.stickers[i].filePath isEqualToString:path]) {
            self.currentSelectItem = i;
            [self.collectionView reloadData];
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            
            return;
        }
    }
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (!enable) {
        [self addGestureRecognizer:[self tapGestureRecongnizer]];
    } else {
        NSArray<UITapGestureRecognizer *> *gestures = [self gestureRecognizers];
        for (UITapGestureRecognizer *gesture in gestures) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [self removeGestureRecognizer:gesture];
            }
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - BECloseableProtocol
- (void)onClose {
    if (self.currentSelectItem > 0) {
        [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectItem inSection:0] animated:false];
        self.currentSelectItem = 0;
        
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BEModernStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BEModernStickerCollectionViewCell be_identifier] forIndexPath:indexPath];
    [cell configureWithSticker:self.stickers[indexPath.row]];
    cell.userInteractionEnabled = self.enable;
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.currentSelectItem != indexPath.row) {
//        [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectItem inSection:0] animated:NO];
//    }
    self.currentSelectItem = indexPath.row;

    if ([self.delegate respondsToSelector:@selector(stickerPicker:didSelectStickerPath:toastString:type:)]) {
        [self.delegate stickerPicker:self didSelectStickerPath:self.stickers[indexPath.row].filePath toastString:self.stickers[indexPath.row].toastString type:self.type];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 70);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 11;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 20, 5, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BEModernStickerCollectionViewCell class] forCellWithReuseIdentifier:[BEModernStickerCollectionViewCell be_identifier]];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (UITapGestureRecognizer *)tapGestureRecongnizer {
    UITapGestureRecognizer *tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self.onTapDelegate action:@selector(onTap)];
    return tapGestureRecongnizer;
}
@end
