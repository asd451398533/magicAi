//
//  FlutterIOSDevicePlugin.m
//  Runner
//
//  Created by Apple on 2019/7/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "FlutterIOSDevicePlugin.h"

@interface FlutterIOSDevicePlugin () {
    NSObject<FlutterPluginRegistrar> *_registrar;
    FlutterViewController *_controller;
}
@end
