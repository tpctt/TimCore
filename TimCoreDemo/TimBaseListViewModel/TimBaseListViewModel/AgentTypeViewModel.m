//
//  AgentTypeViewModel.m
//  TimBaseViewModelDemo
//
//  Created by tim on 16/9/12.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "AgentTypeViewModel.h"

@implementation AgentTypeViewModel
-(void)initialize
{
    [super initialize   ];
    
    self.path = @"public/get-agency";
    
    self.block = ^(NSDictionary *dict){
        return  @[[NSObject new  ]];
    };
    
}



@end



@implementation TagListViewModel
-(void)initialize
{
    [super initialize   ];

    self.path = @"public/get-director-tag";

    
    self.block = ^(NSDictionary *dict){
        return  @[[NSObject new  ]];
    };
    
}



@end
