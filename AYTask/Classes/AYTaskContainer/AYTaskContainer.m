//
//  AYTaskContainer.m
//  AYTaskContainer
//
//  Created by YLCHUN on 2018/5/30.
//  Copyright © 2018年 ylchun. All rights reserved.
//

#import "AYTaskContainer.h"
#import <pthread.h>

static AYTasksReter getTasksReter(NSUInteger count, AYTasksReter tasksReter)
{
    __block NSUInteger completedCount = 0;
    __block NSUInteger successedCount = 0;
    return ^(BOOL success) {
        completedCount ++;
        if (success) successedCount ++;
        if (completedCount == count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                tasksReter(completedCount == successedCount);
            });
        }
    };
}

static AYTaskReter getTaskReter(AYTasksReter tasksReter)
{
    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    __block BOOL isCompleted = NO;
    return ^BOOL(BOOL success) {
        pthread_mutex_lock(&mutex);
        BOOL b;
        if (isCompleted) {
            assert(false);
            b = NO;
        }else {
            isCompleted = YES;
            tasksReter(success);
            b = YES;
        }
        pthread_mutex_unlock(&mutex);
        return b;
    };
}

void runAYTasksIterator(NSArray* datas, AYTaskIterator iterator, AYTasksReter tasksReter)
{
    if (!iterator || !tasksReter) return;
    tasksReter = getTasksReter(datas.count, tasksReter);
    for (id data in datas) {
        iterator(data, getTaskReter(tasksReter));
    }
}



AYTaskUnit getAYTaskUnit(AYTaskBlock taskBlock)
{
    if (!taskBlock) return nil;
    return ^(AYTasksReter tasksReter) {
        taskBlock(getTaskReter(tasksReter));
    };
}

void runAYTasksGroup(NSArray<AYTaskUnit>* tasks, AYTasksReter tasksReter)
{
    if (!tasksReter) return;
    tasksReter = getTasksReter(tasks.count, tasksReter);
    for (AYTaskUnit task in tasks) {
        task(tasksReter);
    }
}
