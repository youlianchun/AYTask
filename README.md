# AYTaskQueue
分组操作 多异步任务绑定执行，可设置任务依赖关系

### 使用说明

```
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
    ...
    AYTask *task5 = ...
    
    TaskQueue *queue = [TaskQueue queueWithToMainCallBack:YES completion:^(AYTaskQueueCarrier *carrier) {
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
