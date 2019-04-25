//
//  AYTaskContainerExample.m
//  TaskContainer
//
//  Created by YLCHUN on 2018/5/30.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "AYTaskContainerExample.h"
@import AYTask;

void testTasksIterator()
{
    runAYTasksIterator(@[@"0", @"1", @"2"], ^(id data, AYTaskReter taskReter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"task:%@", data);
            taskReter(YES);
        });
    }, ^(BOOL success) {
        NSLog(@"finish");
    });
}

void testTasksGroup()
{
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
}
