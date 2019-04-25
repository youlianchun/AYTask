//
//  AYTaskQueue.m
//  AYTaskQueue
//
//  Created by YLCHUN on 2017/5/17.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "AYTaskQueue.h"
#pragma mark -
#pragma mark - AYTimerOut

@interface AYTimerOut : NSObject
-(instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval callBack:(void(^)(void))callback;
-(void)start;
-(void)stop;
@end

@interface AYTimerOut ()
@property (nonatomic, retain) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) void(^callback)(void);
@property (nonatomic, assign) BOOL canCallback;
@end

@implementation AYTimerOut

-(instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval callBack:(void(^)(void))callback {
    self = [super init];
    if (self) {
        self.timeInterval = timeInterval;
        self.callback = callback;
    }
    return self;
}

-(void)dealloc {
    self.timer = nil;
    self.callback = nil;
}

- (void)start {
    self.canCallback = YES;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, self.timeInterval * NSEC_PER_SEC), self.timeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (self.canCallback) {
            self.callback();
            [self stop];
        }
    });
    dispatch_source_set_cancel_handler(timer, ^{
    });
    dispatch_resume(timer);
    self.timer = timer;
}

-(void)stop {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    self.canCallback = NO;
}

@end
#pragma mark -
#pragma mark - AYTask
@interface AYTaskQueue ()
-(void)taskFinish:(AYTask*)task;
-(void)taskQueuSyncDo:(void(^)(void))syncCode;
@end
@interface AYCarrier ()
@property (nonatomic, assign) AYTaskState state;
@property (nonatomic, copy)  NSString * taskFlag;
@end
@interface AYTaskCarrier ()
@property (nonatomic) NSMutableArray<AYCarrier*> *dependency;
@property (nonatomic, retain) AYCarrier *carrier;
@property (nonatomic, weak) AYTask *task;
@end

@interface AYTask()
@property (nonatomic, weak)AYTaskQueue *taskQueue;
@property (nonatomic) NSMutableArray<AYTask*> *dependencyTasks;//依赖表
@property (nonatomic, assign) BOOL runing;//是否正在运行
@property (nonatomic, assign) BOOL didRun;//是否运行过
@property (nonatomic, copy) void(^taskBlock)(AYTaskCarrier *carrier);
@property (nonatomic, retain) AYTaskCarrier *carrier;
@property (nonatomic, retain) AYTimerOut *timer;
@property (nonatomic, assign) BOOL isCancel;
@end
@implementation AYTask
+ (instancetype)taskWithTimeOut:(NSTimeInterval)timeOut task:(void(^)(AYTaskCarrier *carrier))task {
    return [[self alloc] initWithTimeOut:timeOut task:task];
}
- (instancetype)initWithTimeOut:(NSTimeInterval)timeOut task:(void(^)(AYTaskCarrier *carrier))task {
    self = [super init];
    if (self) {
        self.taskBlock = task;
        self.dependencyTasks  = [NSMutableArray array];
        self.carrier = [[AYTaskCarrier alloc] init];
        if (timeOut>0) {            
            __weak typeof(self) wself = self;
            self.timer = [[AYTimerOut alloc] initWithTimeInterval:timeOut callBack:^{
                [wself timerOut];
            }];
        }
        self.carrier.carrier.state = AYTaskStateUnRun;
    }
    return self;
}

-(void)dealloc {
    [self.dependencyTasks removeAllObjects];
    self.dependencyTasks = nil;
    self.carrier = nil;
    self.taskBlock = nil;
    self.timer = nil;
}

-(void)setFlag:(NSString *)flag {
    self.carrier.carrier.taskFlag = flag;
}

-(NSString *)flag {
    return self.carrier.carrier.taskFlag;
}

-(void)start {
    self.didRun = YES;
    self.runing = YES;
    self.carrier.task = self;
    if (self.isCancel) {
        self.runing = NO;
        [self.taskQueue taskFinish:self];
    }else{
        [self.timer start];
        self.carrier.carrier.state = AYTaskStateRuning;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.taskBlock(self.carrier);
        });
    }
}

-(void)filish {
    __weak typeof(self) wself = self;
    [self.taskQueue taskQueuSyncDo:^{
        wself.runing = NO;
        wself.carrier.carrier.state = AYTaskStateFinish;
        [wself.timer stop];
        [wself.taskQueue taskFinish:wself];
    }];
}

-(void)cancel {
    __weak typeof(self) wself = self;
    [self.taskQueue taskQueuSyncDo:^{
        wself.isCancel = YES;
        wself.carrier.carrier.state = AYTaskStateCancel;
        if (wself.runing) {
            wself.runing = NO;
            [wself.timer stop];
            [wself.taskQueue taskFinish:wself];
        }
    }];
}

-(void)timerOut {
    __weak typeof(self) wself = self;
    [self.taskQueue taskQueuSyncDo:^{
        if (wself.runing || !wself.didRun) {
            wself.carrier.carrier.state = AYTaskStateTimerOut;
            wself.runing = NO;
            [wself.taskQueue taskFinish:wself];
        }
    }];
}

- (BOOL)addDependency:(AYTask *)task {
    if (![task dependencyLoopCheckWithTask:self]) {
        [self.dependencyTasks addObject:task];
        [self.carrier.dependency addObject:task.carrier.carrier];
        return YES;
    }else{
        return NO;
    }
}

- (void)removeDependency:(AYTask *)task {
    [self removeDependency:task];
    [self.carrier.dependency removeObject:task.carrier.carrier];
}

- (void)_removeDependency:(AYTask *)task {
    [self.dependencyTasks removeObject:task];
}

-(BOOL)dependencyLoopCheckWithTask:(AYTask*)task {
    if (task == self) {
        return YES;
    }
    for (AYTask* _task in self.dependencyTasks) {
        if(_task == task) {
            return YES;
        }else{
            BOOL b = [_task dependencyLoopCheckWithTask:task];
            if (b) {
                return b;
            }else {
                continue;
            }
        }
    }
    return NO;
}
@end

#pragma mark -
#pragma mark - AYTaskQueue

@interface AYTaskQueueCarrier ()
-(void)addCarrier:(AYTaskCarrier*)carrier ;
@end

@interface AYTaskQueue ()
@property (nonatomic, retain) NSMutableArray<AYTask*> *allTasks;
@property (nonatomic, retain) NSMutableArray<AYTask*> *unrunTasks;
@property (nonatomic, assign) NSUInteger allTasksCount;
@property (nonatomic, assign) BOOL toMain;
@property (nonatomic, assign) BOOL didRun;
@property (nonatomic, copy) void(^completion)(AYTaskQueueCarrier* carrier);
@property (nonatomic, retain) AYTaskQueueCarrier *carrier;
@property (nonatomic, retain) NSOperationQueue *taskQueue;
@property (nonatomic, strong) AYTaskQueue *SELF;
@end

@implementation AYTaskQueue
+ (instancetype)queueWithToMainCallBack:(BOOL)toMain completion:(void(^)(AYTaskQueueCarrier* carrier))completion {
    return [[self alloc] initWithToMainCallBack:toMain completion:completion];
}
- (instancetype)initWithToMainCallBack:(BOOL)toMain completion:(void(^)(AYTaskQueueCarrier* carrier))completion {
    self = [super init];
    if (self) {
        self.toMain = toMain;
        self.completion = completion;
        self.allTasksCount = 0;
        self.maxConcurrentCount = 1;
        self.carrier = [[AYTaskQueueCarrier alloc] init];
        self.allTasks = [NSMutableArray array];
        self.taskQueue = [[NSOperationQueue alloc] init];
        self.taskQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

-(void)dealloc {
    [self.unrunTasks removeAllObjects];
    self.unrunTasks = nil;
    [self.allTasks removeAllObjects];
    self.allTasks = nil;
    self.taskQueue = nil;
    self.carrier = nil;
    self.completion = nil;
}

-(void)retainSelf {
    self.SELF = self;
}

-(void)releaseSelf {
    self.SELF = nil;
}

- (AYTask*)objectAtIndexedSubscript:(NSUInteger)idx {
    if (self.didRun) {
        return nil;
    }
    return [self.allTasks objectAtIndexedSubscript:idx];
}

-(void)addTask:(AYTask*)task {
    if (self.didRun) {
        return;
    }
    [self.allTasks addObject:task];
}

-(void)addTasks:(NSArray<AYTask*>*)tasks {
    if (self.didRun) {
        return;
    }
    for (AYTask *task in tasks) {
        [self addTask:task];
    }
}

-(void)taskFinish:(AYTask*)task {
    for (AYTask *_task in self.unrunTasks) {
        [_task _removeDependency:task];
    }
    [self.allTasks removeObject:task];
    [self _taskFinish:task];
}

-(void)_taskFinish:(AYTask*)task {
    self.allTasksCount -- ;
    if (self.allTasksCount == 0) {
        [self releaseSelf];
        if (self.completion) {
            dispatch_queue_t queue;
            if (self.toMain) {
                queue = dispatch_get_main_queue();
            }else{
                queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            }
            dispatch_async(queue, ^{
                __strong __typeof(self) sself = self;
                sself.completion(sself.carrier);
            });
        }
    }else{
        if (task.didRun) {
            [self runTaskWithCount:1];
        }
    }
}

-(void)run {
    if (self.didRun) {
        return;
    }
    [self retainSelf];
    self.didRun = YES;
    __weak typeof(self)wself = self;
    [self taskQueuSyncDo:^{
        [wself _run];
    }];
}

-(void)cancel {
    [self.taskQueue cancelAllOperations];
    for (AYTask *task in self.allTasks) {
        [task cancel];
    }
}

-(void)_run {
    self.unrunTasks = [self.allTasks mutableCopy];
    self.allTasksCount = self.allTasks.count;
    for (int i = 0; i<self.allTasks.count; i++) {
        [self.carrier addCarrier:self.allTasks[i].carrier];
        self.allTasks[i].taskQueue = self;
    }
    [self runTaskWithCount:self.maxConcurrentCount];
}

-(void)runTaskWithCount:(NSUInteger)count {
    [self runTaskWithCount:count toRun:^(AYTask *task) {
        [task start];
    }];
}

-(void)runTaskWithCount:(NSUInteger)count toRun:(void(^)(AYTask*task))toRun {
    for (NSUInteger i = 0, idx = 0, popCount = 0; popCount < count && i<self.unrunTasks.count && idx < self.unrunTasks.count; i++) {
        AYTask *task = self.unrunTasks[idx];
        if (task.dependencyTasks.count == 0) {
            [self.unrunTasks removeObject:task];
            popCount ++;
            toRun(task);
        }else {
            i--;
            idx ++;
        }
    }
}

-(void)taskQueuSyncDo:(void(^)(void))syncCode {
    [self.taskQueue addOperationWithBlock:^{
        syncCode();
    }];
}


@end
