//
//  ViewController.m
//  AYTask
//
//  Created by YLCHUN on 2017/5/18.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "AYTaskQueue.h"
#import "AYTaskQueue_Leaks.h"
#import "AYTaskContainerExample.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lab_log;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    testTasksIterator();
    testTasksGroup();
    
    for (int i = 0; i<2000; i++) {
        if (i%2 == 0) {
            [self test];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self test];
            });
        }
    }
}

-(void)test {
    AYTask *task1 = [AYTask taskWithTimeOut:2 task:^(AYTaskCarrier *carrier) {
//        AYCarrier *dCarrier_task2 = carrier.dependencyCarrier[0];
//        id param = dCarrier_task2[@"obj2"];//获取依赖参数
        [self netActionWithDelayTime:1 res:^(id obj1, id obj2) {
            if (carrier.isLive) {
                carrier[@"obj1"] = obj1;
                [self logWithString:@"task1"];
                carrier.filish();
            }
        }];
    }];
    task1.flag = @"task1";
    AYTask *task2 = [AYTask taskWithTimeOut:3 task:^(AYTaskCarrier *carrier) {
        [self netActionWithDelayTime:2 res:^(id obj1, id obj2) {
            if (carrier.isLive) {
                carrier[@"obj2"] = obj1;
                [self logWithString:@"task2"];
                carrier.filish();
            }
        }];
    }];
    task2.flag = @"task2";
    AYTask *task3 = [AYTask taskWithTimeOut:3 task:^(AYTaskCarrier *carrier) {
        [self netActionWithDelayTime:2 res:^(id obj1, id obj2) {
            if (carrier.isLive) {
                carrier[@"obj3"] = obj1;
                [self logWithString:@"task3"];
                carrier.filish();
            }
        }];
    }];
    task3.flag = @"task3";
    AYTask *task4 = [AYTask taskWithTimeOut:2 task:^(AYTaskCarrier *carrier) {
        [self netActionWithDelayTime:1 res:^(id obj1, id obj2) {
            if (carrier.isLive) {
                carrier[@"obj4"] = obj1;
                [self logWithString:@"task4"];
                carrier.filish();
            }
        }];
    }];
    task4.flag = @"task4";
    AYTask *task5 = [AYTask taskWithTimeOut:3 task:^(AYTaskCarrier *carrier) {
        [self netActionWithDelayTime:1 res:^(id obj1, id obj2) {
            if (carrier.isLive) {
                carrier[@"obj5"] = obj1;
                [self logWithString:@"task5"];
                carrier.filish();
            }
        }];
    }];
    task5.flag = @"task5";
    AYTaskQueue *queue = [AYTaskQueue queueWithToMainCallBack:YES completion:^(AYTaskQueueCarrier *carrier) {
        AYCarrier *carrier_task1 = carrier[1];
        if (carrier_task1.state == AYTaskStateFinish) {
            [self logWithString:[NSString stringWithFormat:@"completion %@",carrier_task1.taskFlag]];
        }
    }];
    
    [task1 addDependency:task2];
    [task2 addDependency:task4];
    [task2 addDependency:task3];
    [task4 addDependency:task5];
    [task5 addDependency:task1];//存在循环依赖，不会被添加
    [task5 addDependency:task2];//存在循环依赖，不会被添加
    
    [queue addTask:task1];
    [queue addTask:task2];
    [queue addTask:task3];
    [queue addTask:task4];
    [queue addTask:task5];
    
    queue.maxConcurrentCount = 2;
    
    [queue run];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [task2 cancel];
//    });
}

-(void)netActionWithDelayTime:(NSTimeInterval)timer res:(void(^)(id obj1, id obj2))res {
    dispatch_async(dispatch_queue_create("netQueue", NULL), ^{
        [NSThread sleepForTimeInterval:timer];//模拟网络请求延迟
        NSString *resStr = @"netResult";
        if (res) {
            dispatch_async(dispatch_get_main_queue(), ^{
                res(resStr,@"result");
            });
        }
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.lab_log.text = @"";
    for (int i = 0; i<2000; i++) {
        if (i%2 == 0) {
            [self test];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self test];
            });
        }
    }
}

-(void)logWithString:(NSString*)string {
    self.lab_log.text = [NSString stringWithFormat:@"%s %@\n%@", __TIME__, string, self.lab_log.text];
}

@end
