//
//  STCommonObjectContainerView.m
//  SenseMeEffects
//
//  Created by Sunshine on 2017/6/1.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "STCommonObjectContainerView.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define PI 3.14159265358979323846

@interface STCommonObjectContainerView () <STCommonObjectViewDelegate>

@property (nonatomic, readwrite, assign) int newObjectViewID;

@end

@implementation STCommonObjectContainerView

- (void)drawRect:(CGRect)rect {
    
    //    [self drawPoints];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextSetLineWidth(context, 1);
    
    [[UIColor blueColor] set];
    
    //    if (self.faceArray.count > 0) {
    //
    //        for (NSDictionary *dic in self.faceArray) {
    //
    //            if ([dic objectForKey:POINT_KEY]) {
    //                CGPoint point = [[dic objectForKey:POINT_KEY] CGPointValue];
    //                CGContextFillRect(context, CGRectMake(point.x - 1, point.y - 1, 2.0, 2.0));
    //
    //            }
    //        }
    //    }
    if (self.faceArray.count > 0 &&self.step>0) {
        [self drawRZ:context :rect :0];
        [self drawEye:context :rect :1];
        [self drawNose:context :rect :2];
        [self drawLip:context :rect :3];
        [self drawXb:context :rect :4];
        [self drawface:context :rect :5];
//        if(self.radomIndex==0){
//            [self drawEye:context :rect :0];
//            [self drawNose:context :rect :1];
//            [self drawface:context :rect :2];
//        }else if(self.radomIndex==1){
//            [self drawEye:context :rect :0];
//            [self drawNose:context :rect :1];
//            [self drawXb:context :rect :2 ];
//        }else if(self.radomIndex==2){
//            [self drawNose:context :rect :0];
//            [self drawXb:context :rect :1];
//            [self drawface:context :rect :2];
//        }else if(self.radomIndex==3){
//            [self drawEye:context :rect :0];
//            [self drawXb:context :rect :1];
//            [self drawface:context :rect :2];
//        }
    }
    [self.faceArray removeAllObjects];
}

-(void)drawXb :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        CGPoint point =[[self.faceArray[93] objectForKey:POINT_KEY] CGPointValue];
        CGPoint point1 =[[self.faceArray[16] objectForKey:POINT_KEY] CGPointValue];
        if(animValue<0.9){
            [self drawCircle:context :93 :2 :0 :(point1.y-point.y)/2 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing1:context :93 :10.0*newAnimValue+1.5 :3 :0 :(point1.y-point.y)/2];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing1:context :93 :3*newAnimValue+11.5 :3*(1-newAnimValue) :0 :(point1.y-point.y)/2];
        }
        
        if(animValue<0.9){
            CGPoint point =[[self.faceArray[93] objectForKey:POINT_KEY] CGPointValue];
            float newAnimValue=[self saveFloat:(animValue)/9*10];
            [self drawLine:context :point.x :point.y+(point1.y-point.y)/2 :startX :endY :newAnimValue];
        }
        if(animValue>0.3&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.3)/3*10];
            [self showXbElse:context :0.8*newAnimValue :0 :0];
        }
        if(animValue>0.6&&animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self showXbElse:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.4&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.4)/2*10];
            [self showXbElse1:context :0.8*newAnimValue :-1*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.8){
            float newAnimValue=[self saveFloat:(animValue-0.6)/2*10];
            [self showXbElse1:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.45&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.45)/1.5*10];
            [self showXbElse2:context :0.8*newAnimValue :-2.5*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.75){
            float newAnimValue=[self saveFloat:(animValue-0.6)/1.5*10];
            [self showXbElse2:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"下巴加长"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"下巴加长"];
        }
        [self.delegate commonSetBuity:animValue :@"xb"];
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"下巴加长"];
        [self.delegate commonSetBuity:1.0 :@"xb"];
    }
}


-(void)drawface :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        
        float leftX=([[self.faceArray[84] objectForKey:POINT_KEY] CGPointValue].x-
        [[self.faceArray[9] objectForKey:POINT_KEY] CGPointValue].x)/4;
        float rightX=([[self.faceArray[24] objectForKey:POINT_KEY] CGPointValue].x-
        [[self.faceArray[90] objectForKey:POINT_KEY] CGPointValue].x)/4;
        
 
        if(animValue<0.9){
            [self drawCircle:context :8 :2 :leftX :0 :1.0];
            [self drawCircle:context :24 :2 :-rightX :0 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing1:context :8 :10.0*newAnimValue+1.5 :3 :leftX :0];
            [self drawRing1:context :24 :10.0*newAnimValue+1.5 :3 :-rightX :0];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing1:context :8 :3*newAnimValue+11.5 :3*(1-newAnimValue) :leftX :0];
            [self drawRing1:context :24 :3*newAnimValue+11.5 :3*(1-newAnimValue) :-rightX :0];
        }
        if(animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue)/9*10];
            
            CGPoint point =[[self.faceArray[8] objectForKey:POINT_KEY] CGPointValue];
            [self drawLine:context :point.x+leftX :point.y :startX :endY :newAnimValue];
        
            CGPoint point1 =[[self.faceArray[24] objectForKey:POINT_KEY] CGPointValue];
            [self drawLine:context :point1.x-rightX :point1.y :startX :endY :newAnimValue];
        }
        if(animValue>0.3&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.3)/3*10];
            [self showFaceElse2:context :0.8*newAnimValue :0 :0];
        }
        if(animValue>0.6&&animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self showFaceElse2:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.4&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.4)/2*10];
            [self showFaceElse1:context :0.8*newAnimValue :-1*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.8){
            float newAnimValue=[self saveFloat:(animValue-0.6)/2*10];
            [self showFaceElse1:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.45&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.45)/1.5*10];
            [self showFaceElse:context :0.8*newAnimValue :-2.5*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.75){
            float newAnimValue=[self saveFloat:(animValue-0.6)/1.5*10];
            [self showFaceElse:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"脸变瘦"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"脸变瘦"];
        }
        [self.delegate commonSetBuity:animValue :@"face"];
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"脸变瘦"];
        [self.delegate commonSetBuity:1.0 :@"face"];
    }
}



-(void) drawEye :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        [self.delegate commonSetBuity:animValue :@"eye"];
        if(animValue<0.9){
            [self drawCircle:context :74 :2 :0 :0 :1.0];
            [self drawCircle:context :77 :2 :0 :0 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing:context :74 :10.0*newAnimValue+1.5 :3];
            [self drawRing:context :77 :10.0*newAnimValue+1.5 :3];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing:context :74 :3*newAnimValue+11.5 :3*(1-newAnimValue)];
            [self drawRing:context :77 :3*newAnimValue+11.5 :3*(1-newAnimValue)];
        }
        
        if(animValue>0.3&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.3)/3*10];
            [self showEyeElse:context :0.8*newAnimValue :0 :0];
        }
        if(animValue>0.6&&animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self showEyeElse:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.4&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.4)/2*10];
            [self showEyeElse1:context :0.8*newAnimValue :1*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.8){
            float newAnimValue=[self saveFloat:(animValue-0.6)/2*10];
            [self showEyeElse1:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.45&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.45)/1.5*10];
            [self showEyeElse2:context :0.8*newAnimValue :2.5*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.75){
            float newAnimValue=[self saveFloat:(animValue-0.6)/1.5*10];
            [self showEyeElse2:context :0.8*(1-newAnimValue) :0 :0];
        }
        
//        if(animValue>0.1&&animValue<0.8){
//            float newAnimValue=[self saveFloat:(animValue-0.3)/7*10];
//            [self showEyeElse:context :0.0+0.8*animValue          :1*(1-newAnimValue) :1*(1-animValue)];
//        }else if(animValue>0.8){
//             float newAnimValue=[self saveFloat:(animValue-0.8)/2*10];
//            [self showEyeElse:context :0.0+0.8*(1-newAnimValue)          :0.0 :0.0];
//        }
        
        if(animValue>0.6&&animValue<0.9){
            CGPoint point =[[self.faceArray[74] objectForKey:POINT_KEY] CGPointValue];
            CGPoint point1 =[[self.faceArray[77] objectForKey:POINT_KEY] CGPointValue];
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self drawLine:context :point.x :point.y :startX :endY :newAnimValue];
            [self drawLine:context :point1.x :point1.y :startX :endY :newAnimValue];
        }
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"开眼角"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"开眼角"];
        }
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"开眼角"];
        [self.delegate commonSetBuity:1.0 :@"eye"];
    }
}

-(void)drawNose :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        [self.delegate commonSetBuity:animValue :@"nose"];
        if(animValue<0.9){
            [self drawCircle:context :46 :2 :0 :0 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing:context :46 :10.0*newAnimValue+1.5 :3];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing:context :46 :3*newAnimValue+11.5 :3*(1-newAnimValue)];
        }
        
        if(animValue<0.9){
            CGPoint point =[[self.faceArray[46] objectForKey:POINT_KEY] CGPointValue];
            float newAnimValue=[self saveFloat:(animValue)/9*10];
            [self drawLine:context :point.x :point.y :startX :endY :newAnimValue];
        }
        if(animValue>0.3&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.3)/3*10];
            [self showNoseElse2:context :0.8*newAnimValue :0 :0];
        }
        if(animValue>0.6&&animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self showNoseElse2:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.4&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.4)/2*10];
            [self showNoseElse1:context :0.8*newAnimValue :-1*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.8){
            float newAnimValue=[self saveFloat:(animValue-0.6)/2*10];
            [self showNoseElse1:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.45&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.45)/1.5*10];
            [self showNoseElse:context :0.8*newAnimValue :-2.5*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.75){
            float newAnimValue=[self saveFloat:(animValue-0.6)/1.5*10];
            [self showNoseElse:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"鼻翼调整"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"鼻翼调整"];
        }
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"鼻翼调整"];
        [self.delegate commonSetBuity:1.0 :@"nose"];
    }
}

-(void)drawLip :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        [self.delegate commonSetBuity:animValue :@"lip"];
        if(animValue<0.9){
            [self drawCircle:context :102 :2 :0 :0 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing:context :102 :10.0*newAnimValue+1.5 :3];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing:context :102 :3*newAnimValue+11.5 :3*(1-newAnimValue)];
        }
        
        if(animValue<0.9){
            CGPoint point =[[self.faceArray[102] objectForKey:POINT_KEY] CGPointValue];
            float newAnimValue=[self saveFloat:(animValue)/9*10];
            [self drawLine:context :point.x :point.y :startX :endY :newAnimValue];
        }
        if(animValue>0.3&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.3)/3*10];
            [self showLipElse2:context :0.8*newAnimValue :0 :0];
        }
        if(animValue>0.6&&animValue<0.9){
            float newAnimValue=[self saveFloat:(animValue-0.6)/3*10];
            [self showLipElse2:context :0.8*(1-newAnimValue) :0 :0];
        }
        if(animValue>0.4&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.4)/2*10];
            [self showLipElse1:context :0.8*newAnimValue :-1*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.8){
            float newAnimValue=[self saveFloat:(animValue-0.6)/2*10];
            [self showLipElse1:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.45&&animValue<0.6){
            float newAnimValue=[self saveFloat:(animValue-0.45)/1.5*10];
            [self showLipElse:context :0.8*newAnimValue :-2.5*(1-animValue) :0];
        }
        if(animValue>0.6&&animValue<0.75){
            float newAnimValue=[self saveFloat:(animValue-0.6)/1.5*10];
            [self showLipElse:context :0.8*(1-newAnimValue) :0 :0];
        }
        
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"嘴唇变厚"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"嘴唇变厚"];
        }
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"嘴唇变厚"];
        [self.delegate commonSetBuity:1.0 :@"lip"];
    }
}

-(void)drawRZ :(CGContextRef)context :(CGRect)rect :(int)index{
    float startX=rect.size.width-130;
    float endX=rect.size.width-30;
    float startY=150+50*index;
    float endY=180+50*index;
    if(self.step<self.stepCount*(index+1)&&self.step>=self.stepCount*index){
        float animValue=((self.step-self.stepCount*index)/self.stepCount);
        [self.delegate commonSetBuity:animValue :@"rz"];
        if(animValue<0.9){
            [self drawCircle:context :43 :2 :0 :0 :1.0];
        }
        if(animValue<0.3){
            float newAnimValue=[self saveFloat:animValue/3*10];
            [self drawRing:context :43 :10.0*newAnimValue+1.5 :3];
        }else if(animValue>0.3&&animValue<0.7){
            float newAnimValue=[self saveFloat:(animValue-0.3)/4*10];
            [self drawRing:context :43 :3*newAnimValue+11.5 :3*(1-newAnimValue)];
        }
        
        if(animValue<0.9){
            CGPoint point =[[self.faceArray[43] objectForKey:POINT_KEY] CGPointValue];
            float newAnimValue=[self saveFloat:(animValue)/9*10];
            [self drawLine:context :point.x :point.y :startX :endY :newAnimValue];
        }
        
        if(animValue>0.9){
            [self drawFixRect:context :YES :startX :startY :endX :endY :@"眼距变窄"];
        }else{
            [self drawFixRect:context :NO :startX :startY :endX :endY :@"眼距变窄"];
        }
    }else if(self.step>=self.stepCount*(index+1)){
        [self drawFixRect:context :YES :startX :startY :endX :endY :@"眼距变窄"];
        [self.delegate commonSetBuity:1.0 :@"rz"];
    }
}



-(void) drawFixRect :(CGContextRef)context :(BOOL)bright :(float)startX :(float)startY :(float)endX :(float)endY :(NSString*)str{
    CGContextSaveGState(context);
    CGRect rect=CGRectMake(startX, startY, endX-startX, endY-startY);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colorArr = @[(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor,(id)[UIColor colorWithRed:0.71 green:0.866 blue:0.9137 alpha:0.2].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, nil);
            // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    CGContextAddRect(context, rect);
//    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(startX, startY), CGPointMake(endX, endY), 0);
            // 释放gradient
    CGGradientRelease(gradient);
    gradient = NULL;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    UIFont  *font = [UIFont boldSystemFontOfSize:15.0];
    NSMutableParagraphStyle*style = [[NSMutableParagraphStyle alloc]init];
    style.alignment=NSTextAlignmentCenter;
    [str drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:[UIColor blackColor]}];
    CGContextSetLineWidth(context, 2);
    if(bright){
        CGContextSetRGBStrokeColor(context, 0.71, 0.866, 0.9137, 1.0);
    }else{
        CGContextSetRGBStrokeColor(context, 0.21, 0.21, 0.21, 0.5);

    }
    CGContextStrokeRect(context, rect);
    CGContextRestoreGState(context);
}

-(void)drawLine :(CGContextRef)context :(float)startX :(float)startY :(float)endX :(float)endY :(float)percent{
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[3];
    locations[0] = 0;
    locations[1] = percent;
    locations[2] = 1;
    NSArray *colorArr = @[(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0].CGColor,(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8].CGColor,(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, locations);
            // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    CGPoint aPoints[2];//坐标点
    aPoints[0] =CGPointMake(startX, startY);
    aPoints[1] =CGPointMake(endX, endY);
    CGContextAddLines(context, aPoints, 2);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);

    CGContextDrawLinearGradient(context, gradient, CGPointMake(startX, startY), CGPointMake(endX, endY), 0);
            // 释放gradient
    CGGradientRelease(gradient);
    gradient = NULL;
    CGContextRestoreGState(context);
}

-(void)showNoseElse:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :83 :1.5 :0 :0 :alp];
    [self drawCircle:context :51 :1.5 :0 :0 :alp];
    [self drawCircle:context :81 :1.5 :0 :0 :alp];
    [self drawCircle:context :80 :1.5 :0 :0 :alp];
    [self drawCircle:context :82 :1.5 :0 :0 :alp];
    [self drawCircle:context :47 :1.5 :0 :0 :alp];
}

-(void)showNoseElse1:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :83 :1 :5+tranX :0 :alp];
    [self drawCircle:context :51 :1 :5+tranX :2.5 :alp];
    [self drawCircle:context :81 :1 :5+tranX :-2.5 :alp];
    [self drawCircle:context :80 :1 :-5-tranX :-2.5 :alp];
    [self drawCircle:context :82 :1 :-5-tranX :0 :alp];
    [self drawCircle:context :47 :1 :-5-tranX :2.5 :alp];
}
-(void)showNoseElse2:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :83 :0.5 :11+tranX :0 :alp];
    [self drawCircle:context :51 :0.5 :11+tranX :4.5 :alp];
    [self drawCircle:context :81 :0.5 :11+tranX :-4.5 :alp];
    [self drawCircle:context :80 :0.5 :-11-tranX :-4.5 :alp];
    [self drawCircle:context :82 :0.5 :-11-tranX :0 :alp];
    [self drawCircle:context :47 :0.5 :-11-tranX :4.5 :alp];
}

//-------lip

-(void)showFaceElse:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :8 :1.5 :0 :0 :alp];
    [self drawCircle:context :9 :1.5 :0 :0 :alp];
    [self drawCircle:context :10 :1.5 :0 :0 :alp];
    [self drawCircle:context :22 :1.5 :0 :0 :alp];
    [self drawCircle:context :23 :1.5 :0 :0 :alp];
    [self drawCircle:context :23 :1.5 :0 :0 :alp];
}

-(void)showFaceElse1:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :8 :1 :-5-tranX :1.5 :alp];
    [self drawCircle:context :9 :1 :-5-tranX :2.5 :alp];
    [self drawCircle:context :10 :1 :-5-tranX :3.5 :alp];
    
    [self drawCircle:context :22 :1 :5+tranX :1.5 :alp];
    [self drawCircle:context :23 :1 :5+tranX :2.5 :alp];
    [self drawCircle:context :24 :1 :5+tranX :3.5 :alp];
}
-(void)showFaceElse2:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :8 :1 :-11-tranX :2 :alp];
    [self drawCircle:context :9 :1 :-11-tranX :3 :alp];
    [self drawCircle:context :10 :1 :-11-tranX :5 :alp];
    
    [self drawCircle:context :22 :1 :11+tranX :2 :alp];
    [self drawCircle:context :23 :1 :11+tranX :3 :alp];
    [self drawCircle:context :24 :1 :11+tranX :5 :alp];
}


//-------lip

-(void)showLipElse:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :95 :1.5 :0 :0 :alp];
    [self drawCircle:context :94 :1.5 :0 :0 :alp];
    [self drawCircle:context :93 :1.5 :0 :0 :alp];
    [self drawCircle:context :92 :1.5 :0 :0 :alp];
    [self drawCircle:context :91 :1.5 :0 :0 :alp];
}

-(void)showLipElse1:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :95 :1 :-7.5 :5+tranY :alp];
    [self drawCircle:context :94 :1 :-5 :5+tranY :alp];
    [self drawCircle:context :93 :1 :0 :5+tranY :alp];
    
    [self drawCircle:context :92 :1 :5 :5+tranY :alp];
    [self drawCircle:context :91 :1 :7.5 :5+tranY :alp];
}
-(void)showLipElse2:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :95 :1 :-7.5 :11+tranY :alp];
    [self drawCircle:context :94 :1 :-5 :11+tranY :alp];
    [self drawCircle:context :93 :1 :0 :11+tranY :alp];
    
    [self drawCircle:context :92 :1 :5 :11+tranY :alp];
    [self drawCircle:context :91 :1 :7.5 :11+tranY :alp];
}

//-------xb

-(void)showXbElse:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :14 :1.5 :0 :0 :alp];
    [self drawCircle:context :15 :1.5 :0 :0 :alp];
    [self drawCircle:context :16 :1.5 :0 :0 :alp];
    [self drawCircle:context :17 :1.5 :0 :0 :alp];
    [self drawCircle:context :18 :1.5 :0 :0 :alp];
}

-(void)showXbElse1:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :14 :1 :-2.5 :5+tranY :alp];
    [self drawCircle:context :15 :1 :-2.5 :5+tranY :alp];
    [self drawCircle:context :16 :1 :0 :5+tranY :alp];
    [self drawCircle:context :17 :1 :2.5 :5+tranY :alp];
    [self drawCircle:context :18 :1 :2.5 :5+tranY :alp];
}
-(void)showXbElse2:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :14 :0.5 :-10 :11+tranY :alp];
    [self drawCircle:context :15 :0.5 :-7.5 :11+tranY :alp];
    [self drawCircle:context :16 :0.5 :0 :11+tranY :alp];
    [self drawCircle:context :17 :0.5 :7.5 :11+tranY :alp];
    [self drawCircle:context :18 :0.5 :10 :11+tranY :alp];
}




//--------eye
-(void) showEyeElse1:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    
    [self drawCircle:context :52 :1 :-8+tranX :0 :alp];
    [self drawCircle:context :53 :1 :-3+tranX :-8+tranY :alp];
    [self drawCircle:context :72 :1 :0 :-8+tranY :alp];
    [self drawCircle:context :54 :1 :3-tranX :-8+tranY :alp];
    [self drawCircle:context :55 :1 :6 :3 :alp];
    [self drawCircle:context :57 :1 :-3+tranX :8-tranY :alp];
    [self drawCircle:context :73 :1 :0 :8-tranY :alp];
    [self drawCircle:context :56 :1 :3-tranX :8-tranY :alp];
    [self drawCircle:context :79 :1 :0 :0 :alp];
    [self drawCircle:context :58 :0.5 :-6 :3 :alp];
    [self drawCircle:context :59 :1 :-3+tranX :-8+tranY :alp];
    [self drawCircle:context :75 :1 :0 :-8+tranY :alp];
    [self drawCircle:context :60 :1 :3-tranX :-8+tranY :alp];
    [self drawCircle:context :61 :1 :8-tranX :0 :alp];
    [self drawCircle:context :62 :1 :3-tranX :8-tranY :alp];
    [self drawCircle:context :76 :1 :0 :8-tranY :alp];
    [self drawCircle:context :63 :1 :-3+tranX :8-tranY :alp];
    
}
-(void) showEyeElse2:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :52 :0.5 :-12+tranX/2 :0 :alp];
    [self drawCircle:context :53 :0.5 :-6+tranX/2 :-12+tranY/2 :alp];
    [self drawCircle:context :72 :0.5 :0 :-12+tranY/2 :alp];
    [self drawCircle:context :54 :0.5 :6-tranX/2 :-12+tranY/2 :alp];
    [self drawCircle:context :57 :0.5 :-6+tranX/2 :12-tranY/2 :alp];
    [self drawCircle:context :73 :0.5 :0 :12-tranY/2 :alp];
    [self drawCircle:context :56 :0.5 :6-tranX/2 :12-tranY/2 :alp];
    [self drawCircle:context :59 :0.5 :-6+tranX/2 :-12+tranY/2 :alp];
    [self drawCircle:context :75 :0.5 :0 :-12+tranY/2 :alp];
    [self drawCircle:context :60 :0.5 :6-tranX/2 :-12+tranY/2 :alp];
    [self drawCircle:context :61 :0.5 :12-tranX/2 :0 :alp];
    [self drawCircle:context :62 :0.5 :6-tranX/2 :12-tranY/2 :alp];
    [self drawCircle:context :76 :0.5 :0 :12-tranY/2 :alp];
    [self drawCircle:context :63 :0.5 :-6+tranX/2 :12-tranY/2 :alp];
}

-(void) showEyeElse:(CGContextRef)context :(float)alp :(float)tranX :(float)tranY{
    [self drawCircle:context :52 :1.5 :0 :0 :alp];
    [self drawCircle:context :53 :1.5 :0 :0 :alp];
    [self drawCircle:context :72 :1.5 :0 :0 :alp];
    [self drawCircle:context :54 :1.5 :0 :0 :alp];
    [self drawCircle:context :55 :1.5 :0 :0 :alp];
    [self drawCircle:context :57 :1.5 :0 :0 :alp];
    [self drawCircle:context :73 :1.5 :0 :0 :alp];
    [self drawCircle:context :56 :1.5 :0 :0 :alp];
    [self drawCircle:context :78 :1 :0 :0 :alp];
    [self drawCircle:context :58 :1.5 :0 :0 :alp];
    [self drawCircle:context :59 :1.5 :0 :0 :alp];
    [self drawCircle:context :75 :1.5 :0 :0 :alp];
    [self drawCircle:context :60 :1.5 :0 :0 :alp];
    [self drawCircle:context :61 :1.5 :0 :0 :alp];
    [self drawCircle:context :62 :1.5 :0 :0 :alp];
    [self drawCircle:context :76 :1.5 :0 :0 :alp];
    [self drawCircle:context :63 :1.5 :0 :0 :alp];
}



-(float)saveFloat:(float)value{
    if(value<0){
        value=0.0;
    }
    if (value>1) {
        value=1.0;
    }
    return value;
}

-(void) drawCircle:(CGContextRef)context :(int)index :(float)radiu :(int)dx :(int)dy :(float)alp{
    CGContextSaveGState(context);
    CGPoint point =[[self.faceArray[index] objectForKey:POINT_KEY] CGPointValue];
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, alp);
    //    CGContextSetLineWidth(context, 5.0);
    CGContextAddArc(context, point.x+dx, point.y+dy, radiu, 0, 2*PI, 0);
    //    CGContextSetBlendMode(context,kCGBlendModeSourceAtop);
    //    CGContextDrawPath(context, kCGPathFill);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

-(void) drawRing:(CGContextRef)context :(int)index :(float)radiu :(int)stokenWidth {
    CGContextSaveGState(context);
    CGPoint point =[[self.faceArray[index] objectForKey:POINT_KEY] CGPointValue];
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.3);
    if(stokenWidth<0){
        stokenWidth=0;
    }
    CGContextSetLineWidth(context, stokenWidth);
    CGContextAddArc(context, point.x, point.y, radiu, 0, 2*PI, 0);
    CGContextSetBlendMode(context,kCGBlendModeOverlay);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

-(void) drawRing1:(CGContextRef)context :(int)index :(float)radiu :(int)stokenWidth :(double)diffX :(double)diffY{
    CGContextSaveGState(context);
    CGPoint point =[[self.faceArray[index] objectForKey:POINT_KEY] CGPointValue];
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.3);
    if(stokenWidth<0){
        stokenWidth=0;
    }
    CGContextSetLineWidth(context, stokenWidth);
    CGContextAddArc(context, point.x+diffX, point.y+diffY, radiu, 0, 2*PI, 0);
    CGContextSetBlendMode(context,kCGBlendModeOverlay);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.needClear = NO;
    }
    return self;
}

- (void)drawPoints {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    if (!self.needClear) {
        
        CGContextSetLineWidth(context, 2);
        UIColor *greenColor = [UIColor blueColor];
        
        for (NSDictionary *dicPerson in self.arrPersons) {
            
            NSArray *arrPoints = [dicPerson objectForKey:POINTS_KEY];
            if (arrPoints) {
                for (NSDictionary *dicPoint in arrPoints) {
                    [greenColor set];
                    CGPoint point = [[dicPoint objectForKey:POINT_KEY] CGPointValue];
                    CGContextFillRect(context, CGRectMake(point.x - 2.0, point.y - 2.0, 4.0, 4.0));
                }
            }
            
            if ([dicPerson objectForKey:RECT_KEY]) {
                CGContextStrokeRect(context, [[dicPerson objectForKey:RECT_KEY] CGRectValue]);
            }
        }
    } else {
        CGContextClearRect(context, self.bounds);
    }
}







@end
