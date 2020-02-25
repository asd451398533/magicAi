// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernFilterPickerViewController.h"

#import <Masonry/Masonry.h>

#import "BEModernFilterPickerView.h"
#import "BEEffectDataManager.h"
#import "BEStudioConstants.h"

@interface BEModernFilterPickerViewController ()<BEModernFilterPickerViewDelegate>

@property (nonatomic, strong) BEModernFilterPickerView *filterPickerView;
@property (nonatomic, strong) BEEffectDataManager *filterDataManager;
@property (nonatomic, copy) NSArray <BEEffect *> *filters;

@end

@implementation BEModernFilterPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.filterPickerView];
    [self.filterPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self loadData];
    [self setAllCellsUnSelected];
}

#pragma mark - public
- (void)setAllCellsUnSelected{
    [self.filterPickerView setAllCellsUnSelected];
}

- (void)setSelectItem:(NSString *)filterPath {
    [self.filterPickerView setSelectItem:filterPath];
}

#pragma mark - BEModernFilterPickerViewDelegate
- (void)filterPicker:(BEModernFilterPickerView *)pickerView didSelectFilterPath:(NSString *)path {
    [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectFilterDidChangeNotification object:nil userInfo:@{BEEffectNotificationUserInfoKey: path?:@""}];
}

- (void)loadData {
    void(^completion)(BEEffectResponseModel *, NSError *) = ^(BEEffectResponseModel *responseModel, NSError *error) {
        if (!error) {
            self.filters = responseModel.filterGroups.firstObject.filters;
            [self.filterPickerView refreshWithFilters:self.filters];
        }
    };
    [self.filterDataManager fetchDataWithCompletion:^(BEEffectResponseModel *responseModel, NSError *error) {
        completion(responseModel, error);
    }];
}

#pragma mark - getter

- (BEModernFilterPickerView *)filterPickerView {
    if (!_filterPickerView) {
        _filterPickerView = [[BEModernFilterPickerView alloc] init];
        _filterPickerView.delegate = self;
    }
    return _filterPickerView;
}

- (BEEffectDataManager *)filterDataManager {
    if (!_filterDataManager) {
        _filterDataManager = [BEEffectDataManager dataManagerWithType:BETypeFilter];
    }
    return _filterDataManager;
}

@end
