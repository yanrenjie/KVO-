//
//  ViewController.m
//  KVO原理探究
//
//  Created by 颜仁浩 on 2018/3/23.
//  Copyright © 2018年 颜仁浩. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "NSObject+AJieKVO.h"

@interface ViewController ()
@property(nonatomic, strong)Student *student;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    Student *stu = [[Student alloc] init];
    [stu jie_addObserver:self forKeyPath:@"stu_name" options:0 context:@"Student"];
    _student = stu;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int i = 0;
    NSString *name = [NSString stringWithFormat:@"stu_name%d", i];
    _student.stu_name = name;
}

@end
