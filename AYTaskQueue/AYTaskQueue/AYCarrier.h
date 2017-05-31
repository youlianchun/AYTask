//
//  AYCarrier.h
//  AYTaskQueue
//
//  Created by YLCHUN on 2017/5/18.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    AYTaskStateUnRun       = 0,
    AYTaskStateRuning      = 1,
    AYTaskStateCancel      = 2,
    AYTaskStateFinish      = 3,
    AYTaskStateTimerOut    = 4,
}AYTaskState;

@class AYTaskQueueCarrier;

@interface AYCarrier : NSObject
/*任务状态*/
@property (nonatomic, readonly) AYTaskState state;
/*任务标记，task.flag*/
@property (nonatomic, readonly)  NSString * _Nullable taskFlag;
/*根据key获取值*/
- (__nullable id)objectForKeyedSubscript:(__nonnull id<NSCopying>)key;
@end

@interface AYTaskCarrier : NSObject
/*任务是否还存活*/
@property (nonatomic, readonly) BOOL isLive;
/*依赖对象结果集，与依赖添加顺序一致*/
@property (nonatomic, readonly) NSArray<AYCarrier*> * _Nullable dependencyCarrier;
/*任务完成*/
@property (nonatomic, readonly) void(^ _Nonnull filish)();
/*根据key获取值*/
- (__nullable id)objectForKeyedSubscript:(__nonnull id<NSCopying>)key;
/*根据key设置值*/
- (void)setObject:(__nullable id)obj forKeyedSubscript:(__nonnull id<NSCopying>)key;
@end

@interface AYTaskQueueCarrier : NSObject
/*根据下标获取任务结果集*/
- (AYCarrier* _Nullable )objectAtIndexedSubscript:(NSUInteger)idx;
@end


