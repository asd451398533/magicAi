//
//  FlutterIOSDevicePlugin.h
//  Runner
//
//  Created by Apple on 2019/7/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

@interface FlutterIOSDevicePlugin : NSObject<FlutterPlugin>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar flutterViewController:(FlutterViewController*) controller;
- (instancetype)newInstance:(NSObject<FlutterPluginRegistrar>*)registrar flutterViewController:(FlutterViewController*) controller;
@end


