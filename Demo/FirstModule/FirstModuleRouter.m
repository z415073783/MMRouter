//
//  FirstModuleRouter.m
//  Demo
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

#import "FirstModuleRouter.h"
#import "FirstViewController.h"
#import <MMRouter/MMRouter-Swift.h>
@implementation FirstModuleRouter
+(FirstModuleRouter*)shared {
    static FirstModuleRouter* _shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [FirstModuleRouter new];
    });
    
    return _shared;
}

+(void)registerModule {
    
    [MMRouter registerWithTarget:[FirstModuleRouter shared] key:@"openFirstVC" block:^(id nullable, void (^ callBlock)(id nullable)) {
        FirstViewController* vc = [FirstViewController new];
        if (callBlock) {
            callBlock(vc);
        }
    }];

    
}
@end
