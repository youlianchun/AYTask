//
//  AYTaskQueue_Leaks.m
//  AYTaskQueue
//
//  Created by YLCHUN on 2017/5/19.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "AYTaskQueue_Leaks.h"

@implementation AYTaskQueue_Leaks
//-(void)releaseSelf {
//
//}
//  代码likes测试泄露是因为AYTaskQueue在执行时候进行了自我引用，实际上并不存在泄漏，
//  内存泄露测试可继承 AYTaskQueue 重写 releaseSelf retainSelf方法后进行
-(void)retainSelf {
    static NSMutableArray *kAarray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAarray = [NSMutableArray array];
    });
    [kAarray addObject:self];
}
@end
