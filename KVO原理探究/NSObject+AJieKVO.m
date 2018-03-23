//
//  NSObject+AJieKVO.m
//  OCTestProject
//
//  Created by 颜仁浩 on 2018/3/23.
//  Copyright © 2018年 颜仁浩. All rights reserved.
//

#import "NSObject+AJieKVO.h"
#import <objc/message.h>

@implementation NSObject (AJieKVO)

- (void)jie_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    // 1. 获取调用当前方法的对象所属的类的类名
    NSString *oldClassName = NSStringFromClass([self class]);
    // 创建子类的类名，是通过在父类类名前面加上AJieKVONotifing_前缀
    NSString *newClassName = [NSString stringWithFormat:@"%@%@", @"AJieKVONotifing_", oldClassName];
    // 2. 新建一个OldClass的子类AJieKVONotifing_
    Class newClass = objc_allocateClassPair([self class], [newClassName UTF8String], 0);
    // 3. 为子类的被观察的属性添加setter方法
    //  获取当前所被观察的属性的名称，即keyPath的值，假设我们这儿只观察一级，不涉及xx.xx.xx
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[keyPath substringToIndex:1] uppercaseString], [keyPath substringFromIndex:1]];
    NSLog(@"setterName ===  %@", setterName);
    SEL setterSEL = NSSelectorFromString(setterName);
    class_addMethod(newClass, setterSEL, (IMP)setterMethod, "v@:@");
    // 4. 注册子类
    objc_registerClassPair(newClass);
    // 5. 修改isa指针指向，将当前对象的isa指针指向新创建的子类
    object_setClass(self, newClass);
    // 6. 保存observer， keypath, options context 等信息，用于在setter方法发送消息用
    objc_setAssociatedObject(self, "jie_observer", observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "jie_keyPath", keyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "jie_options", @(options), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "jie_context", CFBridgingRelease(context), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, "jie_setter", setterName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// 1. 重写setter方法，首先要调用super的setter方法
// 2. 通知外界
void setterMethod(id self, SEL _cmd, NSString *args) {
    // 调用super的setter方法，通过运行时发送消息
    // 获取当前类
    Class currentClass = [self class];
    // 获取当前对象类的父类
    Class fatherClass = class_getSuperclass(currentClass);
    // 修改isa指针指向，指向父类，然后发送消息
    object_setClass(self, fatherClass);
    // 发送消息，调用setter方法
    // 1. 获取setter方法名称
    id setterName = objc_getAssociatedObject(self, "jie_setter");
    SEL setterSEL = NSSelectorFromString((NSString *)setterName);
    objc_msgSend(self, setterSEL, args);
    
    // 获取保存的observer， keypath, options context 等信息
    id observer = objc_getAssociatedObject(self, "jie_observer");
    id keyPath = objc_getAssociatedObject(self, "jie_keyPath");
    id options = objc_getAssociatedObject(self, "jie_options");
    id context = objc_getAssociatedObject(self, "jie_context");
    
    // 通知外界的观察者  observeValueForKeyPath
    objc_msgSend(observer, @selector(observeValueForKeyPath:ofObject:change:context:), self, keyPath, [(NSNumber *)options unsignedIntegerValue], context);
    // 修改回isa指针指向
    
    object_setClass(self, currentClass);
}

@end
