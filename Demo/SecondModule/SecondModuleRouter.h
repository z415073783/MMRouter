//
//  SecondModuleRouter.h
//  Demo
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecondModuleRouter : NSObject
+(SecondModuleRouter*)shared;
+(void)registerModule;
@end

NS_ASSUME_NONNULL_END
