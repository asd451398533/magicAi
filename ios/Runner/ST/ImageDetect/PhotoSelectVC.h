//
//  PhotoSelectVC.h
//  SenseMeEffects
//
//  Created by Sunshine on 22/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoSelectVCDismissDelegate <NSObject>

- (void)photoSelectVCDidDismiss;

@end

@interface PhotoSelectVC : UIViewController

@property (nonatomic , weak) id <PhotoSelectVCDismissDelegate> delegate;

@end
