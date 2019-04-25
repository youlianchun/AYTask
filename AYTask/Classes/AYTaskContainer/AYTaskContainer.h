//
//  AYTaskContainer.h
//  AYTaskContainer
//
//  Created by YLCHUN on 2018/5/30.
//  Copyright © 2018年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^AYTaskReter)(BOOL success);
typedef void(^AYTasksReter)(BOOL success);
typedef void(^AYTaskIterator)(id data, AYTaskReter taskReter);
typedef void(^AYTaskUnit)(AYTasksReter);
typedef void(^AYTaskBlock)(AYTaskReter taskReter);

OBJC_EXTERN void runAYTasksIterator(NSArray* datas, AYTaskIterator iterator, AYTasksReter tasksReter);

// getAYTaskUnit  runAYTasksGroup  两函数结合使用
OBJC_EXTERN AYTaskUnit getAYTaskUnit(AYTaskBlock taskBlock);
OBJC_EXTERN void runAYTasksGroup(NSArray<AYTaskUnit>* tasks, AYTasksReter tasksReter);
