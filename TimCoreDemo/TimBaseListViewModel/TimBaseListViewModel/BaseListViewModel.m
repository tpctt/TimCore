//
//  BaseViewModel.m
//  TimBaseViewModelDemo
//
//  Created by tim on 16/9/6.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "BaseListViewModel.h"

#import <AdSupport/AdSupport.h>
#import <CoreSpotlight/CoreSpotlight.h>





@implementation BaseViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        [self initNetError];
        [self setBaseUrl:@"http://api.xxx.com/v3/"];

        [self setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];

        
    }
    return self;
}


-(void)dealloc
{
    
    NSLog(@"dealloc %@--%@", NSStringFromClass(self.class),self.path );
    
}

-(void)initNetError
{
    [self.command.errors subscribeNext:^(NSError *error) {
        if (error.code == -2 ) {
            
        }
        
    }];
     
    
}
#pragma mark cache

#pragma mark 实现过程



@end



////
@implementation BaseListViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setBaseUrl:@"http://api.xxx.com/v3/"];
//        [self initNetError];
        [self setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];
        
        
    }
    return self;
}



@end
