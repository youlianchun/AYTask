//
//  AYTaskQueue.h
//  AYTaskQueue
//
//  Created by YLCHUN on 2017/5/17.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//
//  AYTaskQueue，AYTask 为一次性实例
//  代码likes测试泄露是因为AYTaskQueue在执行时候进行了自我引用，实际上并不存在泄漏，
//  内存泄露测试可继承 AYTaskQueue 重写 releaseSelf retainSelf方法后进行
//-(void)releaseSelf {
//
//}
//-(void)retainSelf {
//    static NSMutableArray *kAarray;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        kAarray = [NSMutableArray array];
//    });
//    [kAarray addObject:self];
//}

#import <Foundation/Foundation.h>
#import "AYCarrier.h"

@interface AYTask : NSObject
@property (nonatomic, copy) NSString *flag;//任务标记，建议设置
@property (nonatomic, readonly) BOOL runing;//是否正在运行
@property (nonatomic, readonly) BOOL didRun;//是否运行过
- (instancetype)initWithTimeOut:(NSTimeInterval)timeOut task:(void(^)(AYTaskCarrier *carrier))task;
- (void)cancel;

/**
 移除依赖

 @param task <#task description#>
 */
- (void)removeDependency:(AYTask *)task;

/**
 添加依赖，导致循环依赖，不会被添加

 @param task 依赖任务
 @return 添加结果
 */
- (BOOL)addDependency:(AYTask *)task;


+ (instancetype)taskWithTimeOut:(NSTimeInterval)timeOut task:(void(^)(AYTaskCarrier *carrier))task;

@end


@interface AYTaskQueue : NSObject
@property (nonatomic, assign) NSUInteger maxConcurrentCount;
- (instancetype)initWithToMainCallBack:(BOOL)toMain completion:(void(^)(AYTaskQueueCarrier* carrier))completion;
-(void)cancel;
-(void)run;
-(void)addTask:(AYTask*)task;
-(void)addTasks:(NSArray<AYTask*>*)tasks;
- (AYTask*)objectAtIndexedSubscript:(NSUInteger)idx;


+ (instancetype)queueWithToMainCallBack:(BOOL)toMain completion:(void(^)(AYTaskQueueCarrier* carrier))completion;

@end
