//
//  CSSearch.m
//  KehuFox
//
//  Created by tim on 17/1/18.
//  Copyright © 2017年 timRabbit. All rights reserved.
//

#import "TimCoreAppDelegate+CSSearch.h"
#import <TimSearchItemForObjectProtocol.h>



@interface TimCoreAppDelegate()

@end

@implementation  TimCoreAppDelegate(CSSearch)
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable restorableObjects ))restorationHandler
{
//    restorationHandler(@[]);
//    NSLog(@"%@,",restorableObjects);

    if ([userActivity.activityType isEqualToString:@"com.apple.corespotlightitem"] ) {
        
        ///spot
        NSString *kCSSearchableItemActivityIdentifier = [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
        
        NSData *data = [kCSSearchableItemActivityIdentifier dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        
        
        NSString *class = [info objectForKey:@"class"];
        NSDictionary *mj_keyValues = [info objectForKey:@"mj_keyValues"];
        
        NSObject *object = [[NSClassFromString(class) alloc] init];
        if ([object conformsToProtocol:@protocol(TimSearchItemForObjectProtocol) ] && [object respondsToSelector:@selector(continueUserActivityWith:)]) {
            
            NSObject<TimSearchItemForObjectProtocol > *objectProtocol = object;
            
            [objectProtocol continueUserActivityWith:mj_keyValues];
            

        }
         
        
    }else if ([userActivity.activityType isEqualToString:@"com.cxb360.KehuFox.accountPwdInfo"] ) {
        ///handoff
        
        
        
    }
    
    
    
    
    
    
    return YES;
    
}

@end
