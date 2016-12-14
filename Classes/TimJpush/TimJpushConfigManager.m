//
//  jiaGTConfigManager.m
//  Pods
//
//  Created by wujunyang on 16/7/7.
//
//

#import "TimJpushConfigManager.h"

@implementation TimJpushConfigManager

+ (TimJpushConfigManager *)sharedInstance
{
    static TimJpushConfigManager* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TimJpushConfigManager new];
        instance.apsForProduction = YES;
        
        
        
    });

    return instance;
}


@end
