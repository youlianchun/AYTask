//
//  AYCarrier.m
//  AYTaskQueue
//
//  Created by YLCHUN on 2017/5/18.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "AYCarrier.h"
#pragma mark -
#pragma mark - AYCarrier
@interface AYCarrier ()
{
    NSMutableDictionary *_carrierDictionary;
}
@property (nonatomic, assign) AYTaskState state;
@property (nonatomic, copy) NSString * taskFlag;
@end
@implementation AYCarrier

-(instancetype)init {
    self = [super init];
    if (self) {
        _carrierDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)dealloc {
    _carrierDictionary = nil;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    return [_carrierDictionary objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [_carrierDictionary setObject:obj forKeyedSubscript:key];
}

@end


#pragma mark - 
#pragma mark - AYTaskCarrier
#import "AYTaskQueue.h"

@interface AYTask ()
-(void)filish;
@end
@interface AYTaskCarrier ()
@property (nonatomic) NSMutableArray<AYCarrier*> *dependency;
@property (nonatomic, retain) AYCarrier *carrier;
@property (nonatomic, weak) AYTask *task;
@property (nonatomic, copy) void(^filish)(void);
@end

@implementation AYTaskCarrier
-(instancetype)init {
    self = [super init];
    if (self) {
        self.carrier = [[AYCarrier alloc] init];
        self.dependency = [NSMutableArray array];
        __weak typeof(self) wself = self;
        __block BOOL didFinish = NO;
        self.filish = ^(void){
            if (didFinish) return;
            didFinish = YES;
            [wself.task filish];
        };
    }
    return self;
}
-(void)dealloc {
    self.carrier = nil;
    self.task = nil;
    [self.dependency removeAllObjects];
    self.dependency = nil;
    self.filish = nil;
}

-(NSArray *)dependencyCarrier {
    if (self.dependency.count>0) {
        return self.dependency;
    }
    return nil;
}

-(BOOL)isLive {
    return self.task.runing;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    return [self.carrier objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self.carrier setObject:obj forKeyedSubscript:key];
}

@end

#pragma mark -
#pragma mark - AYTaskQueueCarrier
@interface AYTaskQueueCarrier ()
{
    NSMutableArray<AYCarrier*> *_carrierArray;
}
@end
@implementation AYTaskQueueCarrier
-(instancetype)init {
    self = [super init];
    if (self) {
        _carrierArray = [NSMutableArray array];
    }
    return self;
}

-(void)dealloc {
    _carrierArray = nil;
}

- (AYCarrier*)objectAtIndexedSubscript:(NSUInteger)idx {
    return [_carrierArray objectAtIndexedSubscript:idx];
}

-(void)addCarrier:(AYTaskCarrier*)carrier {
    [_carrierArray addObject:carrier.carrier];
}

@end

