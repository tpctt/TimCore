//
//  TQBCheckViewModel.m
//  taoqianbao
//
//  Created by tim on 16/9/27.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "TQBCheckViewModel.h"

@implementation TQBCheckViewModel

- (void)initialize {
    
    [super initialize];
    
    @weakify(self)
    
    
    self.path = @"public/version";
    
    self.inputBlock = ^NSMutableDictionary *(NSMutableDictionary *para){
    
        return para;
    };
    
    self.outputBlock = ^id (NSDictionary *dict){
        @strongify(self);
        
        if([dict isKindOfClass:[NSDictionary class]] == NO){
            return nil;
        }
        
//        self.versionObj =  [TQBCheckModel mj_objectWithKeyValues:dict];
        self.versionObj =  [TQBCheckModel new];
        
        return  self.versionObj ;
        
    };
    
    
    
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        [self setBaseUrl:@"http://api.kehufox.com/v1/"];
        
        [self setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];
        
        
    }
    return self;
}


@end

@implementation TQBCheckModel

@end
