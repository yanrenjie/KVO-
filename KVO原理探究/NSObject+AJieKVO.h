//
//  NSObject+AJieKVO.h
//  OCTestProject
//
//  Created by 颜仁浩 on 2018/3/23.
//  Copyright © 2018年 颜仁浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AJieKVO)
- (void)jie_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end
