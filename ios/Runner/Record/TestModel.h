//
//  TestModel.h
//  Runner
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef TestModel_h
#define TestModel_h


#endif /* TestModel_h */

@interface TestModel : NSObject
@property(nonatomic,copy)NSString *name;//姓名
@property(nonatomic,copy)NSArray *arr;//姓名
@property(nonatomic)NSMutableDictionary* map;
+(NSMutableArray*) getDemoData;
@end
