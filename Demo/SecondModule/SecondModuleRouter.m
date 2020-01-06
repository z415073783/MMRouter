//
//  SecondModuleRouter.m
//  Demo
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

#import "SecondModuleRouter.h"
#import "SecondViewController.h"
#import <MMRouter/MMRouter-Swift.h>
@implementation SecondModuleRouter
+(SecondModuleRouter*)shared {
    static SecondModuleRouter* _shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [SecondModuleRouter new];
    });
    
    return _shared;
}

+(void)registerModule {
    
    [MMRouter registerWithTarget:[SecondModuleRouter shared] key:@"openSecondVC" block:^(id nullable, void (^ callBlock)(id nullable)) {
        SecondViewController* vc = [SecondViewController new];
        if (callBlock) {
            callBlock(vc);
        }
    }];

    
}
@end
