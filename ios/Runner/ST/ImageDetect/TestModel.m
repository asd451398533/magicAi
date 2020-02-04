//
//  TestModel.m
//  Runner
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestModel.h"

@implementation TestModel

+(NSArray*) getDemoData{
    NSMutableArray *dataArry=[NSMutableArray array];
    TestModel * m0 =[[TestModel alloc]init];
    m0.name = @"原图";
    m0.arr=@[@0.0f,@0.0f,@0.0f ,@0.0f    ,@0.0f,    @0.0f    ,@0.0f    ,@0.0f ,@0.0f,@0.0f   , @0.0f   ,@0.0f    ,@0.0f   , @0.0f    ,@0.0f    ,@0.0f    ,@0.0f   ,@ 0.0f];
    TestModel * m10086 =[[TestModel alloc]init];
    m10086.name = @"测试脸";
    m10086.arr=@[@0.0f,@0.0f,@0.0f ,@0.0f    ,@0.0f,    @0.0f    ,@0.0f    ,@0.0f ,@0.0f,@0.0f   , @0.0f   ,@0.0f    ,@0.0f   , @0.0f    ,@0.0f    ,@0.0f    ,@0.0f   ,@ 0.0f];
    
    
    TestModel * m1 =[[TestModel alloc]init];
    m1.name = @"幼幼脸男";
    m1.arr=@[@0.0f,@0.0f,@0.69f ,@0.0f    ,@0.54f,    @0.0f    ,@0.18f    ,@1.0f ,@1.0f,@0.0f   , @-0.53f   ,@0.0f    ,@0.36f   , @0.0f    ,@1.0f    ,@0.0f    ,@0.0f   ,@ 0.0f];
   
    
    
    TestModel * m2 =[[TestModel alloc]init];
    m2.name = @"幼幼脸";
    m2.arr=@[ @0.0f,    @0.0f    ,@0.0f,    @0.0f     ,@0.35f ,@0.0f    ,@-0.87f    ,@1.0f    ,@1.0f    ,@0.0f    ,@-0.76f    ,@0.59   ,@1.0f    ,@0.0f    ,@0.72f    ,@0.0f    ,@0.0f    ,@1.0f];


    
    TestModel * m3 =[[TestModel alloc]init];
    m3.name = @"网红脸男";
    m3.arr=@[@0.0f,@0.0f,@0.64f,@0.0f,@0.13f,@0.0f,@-0.59f,@0.46f,@1.0f,@0.0f,@0.0f,@0.69f,@0.51f,@0.0f,@1.0f,@0.0f,@0.0f,@0.49f];
    TestModel * m4 =[[TestModel alloc]init];
    m4.name = @"日系脸";
    m4.arr=@[@0.50f,@0.53f,@0.92f,@0.20f,@0.29f,@0.27f,@-0.15f,@0.12f,@1.0f,@0.35f,@-0.36f,@0.33f,@0.37f,@0.0f,@0.31f,@1.0f,@1.0f,@1.0f];
    TestModel * m5 =[[TestModel alloc]init];
    m5.name = @"日系脸男";
    m5.arr=@[@0.65f,@0.53f,@0.23f,@0.10f,@0.23f,@1.0f,@-0.81f,@0.43f,@1.0f,@0.31f,@0.10f,@0.04f,@0.81f,@0.32f,@1.0f,@0.59f,@1.0f,@1.0f];
    TestModel * m6 =[[TestModel alloc]init];
    m6.name = @"平均脸";
    m6.arr=@[@0.0f,@0.0f,@0.64f,@0.0f,@0.13f,@0.0f,@-0.59f,@0.46f,@1.0f,@0.0f,@0.0f,@0.69f,@0.51f,@0.0f,@1.0f,@0.0f,@0.0f,@0.49f];
    TestModel * m7 =[[TestModel alloc]init];
    m7.name = @"变年轻男";
    m7.arr=@[@0.0f,@0.31f,@0.58f,@0.0f,@0.14f,@0.0f,@-0.51f,@-1.0f,@1.0f,@0.0f,@0.0f,@0.0f,@0.68f,@0.0f,@0.0f,@0.0f,@1.0f,@1.0f];
    TestModel * m8 =[[TestModel alloc]init];
    m8.name = @"变年轻";
    m8.arr=@[@0.0f,@0.27f,@0.13f,@0.0f,@0.0f,@0.0f,@0.15f,@0.0f,@1.0f,@0.13f,@-0.03f,@0.61f,@1.0f,@0.56f,@0.36f,@0.0f,@1.0f,@1.0f];
    
    TestModel * m9 =[[TestModel alloc]init];
    m9.name = @"初恋脸";
    
    m9.arr=@[@0.0f,@0.28f,@0.33f,@0.0f,@0.33f,@-0.50f,@-0.25f,@0.58f,@1.0f,@0.0f,@-0.40f,@-0.30f,@0.48f,@0.42f,@0.45f,@0.0f,@0.55f,@0.60f];
 
    
    TestModel * m10 =[[TestModel alloc]init];
       m10.name = @"小鹿脸";
       m10.arr=@[@0.52f,@0.0f,@0.57f,@0.38f,@0.30f,@0.64f,@0.0f,@-0.62f,@1.0f,@0.31f,@-0.24f,@0.38f,@0.64f,@-0.52f,@0.0f,@0.0f,@1.0f,@1.0f];
    
    TestModel * m11 =[[TestModel alloc]init];
          m11.name = @"优雅脸";
          m11.arr=@[@0.36f,@0.12f,@0.09f,@0.04f,@0.50f,@0.22f,@0.04f,@0.0f,@0.40f,@0.10f,@0.06f,@0.35f,@0.12f,@0.0f,@0.0f,@0.29f,@1.0f,@0.50f];
    
    TestModel * m12 =[[TestModel alloc]init];
             m12.name = @"韩系脸";
             m12.arr=@[@0.56f,@0.34f,@0.30f,@0.52f,@0.31f,@0.16f,@0.08f,@0.12f,@1.0f,@0.16f,@0.0f,@0.21f,@0.38f,@-0.19f,@0.37f,@0.0f,@1.0f,@1.0f];

    TestModel * m13 =[[TestModel alloc]init];
             m13.name = @"古典脸";
             m13.arr=@[@0.50f,@0.0f,@0.0f,@0.14f,@0.22f,@0.31f,@0.0f,@0.0f,@0.50f,@0.21f,@0.0f,@0.07f,@0.36f,@-0.57f,@0.0f,@0.35f,@1.0f,@1.0f];
    
    TestModel * m14 =[[TestModel alloc]init];
                m14.name = @"攻气脸";
                m14.arr=@[@0.67f,@0.20f,@0.0f,@0.24f,@0.0f,@0.25f,@-0.25f,@0.0f,@1.0f,@0.35f,@0.27f,@0.58f,@0.0f,@-0.85f,@-0.28f,@0.20f,@1.0f,@1.0f];

    
    [dataArry addObject:m0];
    [dataArry addObject:m10086];
//    [dataArry addObject:m1];
    [dataArry addObject:m2];
//    [dataArry addObject:m3];
    [dataArry addObject:m4];
//    [dataArry addObject:m5];
    [dataArry addObject:m6];
//    [dataArry addObject:m7];
//    [dataArry addObject:m8];
    [dataArry addObject:m9];
    
    [dataArry addObject:m10];
    [dataArry addObject:m11];
    [dataArry addObject:m12];
    [dataArry addObject:m13];
    [dataArry addObject:m14];
    return dataArry;
}

@end
