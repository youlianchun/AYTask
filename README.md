# AYTask

[![CI Status](https://img.shields.io/travis/youlianchun/AYTask.svg?style=flat)](https://travis-ci.org/youlianchun/AYTask)
[![Version](https://img.shields.io/cocoapods/v/AYTask.svg?style=flat)](https://cocoapods.org/pods/AYTask)
[![License](https://img.shields.io/cocoapods/l/AYTask.svg?style=flat)](https://cocoapods.org/pods/AYTask)
[![Platform](https://img.shields.io/cocoapods/p/AYTask.svg?style=flat)](https://cocoapods.org/pods/AYTask)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### AYTaskQueue
```
AYTask *task1 = [AYTask taskWithTimeOut:2 task:^(AYTaskCarrier *carrier) {
//   AYCarrier *dCarrier_task2 = carrier.dependencyCarrier[0];
//   id param = dCarrier_task2[@"obj2"];//获取依赖参数
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
```
#### AYTaskContainer
```
runAYTasksIterator(@[@"0", @"1", @"2"], ^(id data, AYTaskReter taskReter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"task:%@", data);
            taskReter(YES);
        });
    }, ^(BOOL success) {
        NSLog(@"finish");
});

NSMutableArray *tasks = [NSMutableArray array];
[tasks addObject:getAYTaskUnit(^(AYTaskReter taskReter) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"task0");
        taskReter(YES);
    });
})];
[tasks addObject:getAYTaskUnit(^(AYTaskReter taskReter) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"task1");
        taskReter(YES);
    });
})];
[tasks addObject:getAYTaskUnit(^(AYTaskReter taskReter) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"task2");
        taskReter(YES);
    });
})];

runAYTasksGroup(tasks, ^(BOOL success) {
    NSLog(@"finish a");
});
runAYTasksGroup(tasks, ^(BOOL success) {
    NSLog(@"finish b");
});
```

## Requirements

## Installation

AYTask is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AYTask'
```

## Author

youlianchun, youlianchunios@163.com

## License

AYTask is available under the MIT license. See the LICENSE file for more info.
