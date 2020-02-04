//
//  STCommonObjectContainerView.h
//  SenseMeEffects
//
//  Created by Sunshine on 2017/6/1.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCommonObjectView.h"

#define POINT_KEY @"POINT_KEY"
#define POINTS_KEY @"POINTS_KEY"
#define RECT_KEY @"RECT_KEY"

@class STCommonObjectView;

@protocol STCommonObjectContainerViewDelegate <NSObject>

@optional
- (void)commonObjectViewFinishTrackingFrame:(CGRect)frame;
- (void)commonObjectViewStartTrackingFrame:(CGRect)frame;
-(void)commonSetBuity:(float)progress :(NSString*)what;

@end

@interface STCommonObjectContainerView : UIView

@property (nonatomic, readwrite, strong) STCommonObjectView *currentCommonObjectView;
@property (nonatomic, readwrite, weak) id<STCommonObjectContainerViewDelegate> delegate;
@property (nonatomic, strong) NSArray *arrPersons;
@property (nonatomic, assign) BOOL needClear;

@property (nonatomic, strong) NSMutableArray *faceArray;
@property(nonatomic,strong) NSMutableDictionary<NSString*,NSString*>* dict;
@property(nonatomic)int step;
@property(nonatomic) float stepCount;
@property(nonatomic) int radomIndex;

- (void)addCommonObjectViewWithImage:(UIImage *)image;

@end
