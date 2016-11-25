//
//  XAspect-LogAppDelegate.m
//  MobileProject 抽离原本应在AppDelegate的内容（个推）
//
//  Created by wujunyang on 16/6/22.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "TimCoreAppDelegate+share.h"
#import "TimCoreAppDelegate.h"
#import "TimShareConfigManager.h"

#import <XAspect.h>
#import <ShareSDK/ShareSDK.h>

#define AtAspect ShareAppDelegate

#define AtAspectOfClass TimCoreAppDelegate

@interface  TimCoreAppDelegate ()

@end


@classPatchField(TimCoreAppDelegate)

@synthesizeNucleusPatch(Default, -, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);


@synthesizeNucleusPatch(Default,-,void, dealloc);

/** app 启动过程 **/
AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    
    if ([TimShareConfigManager sharedInstance].enableShare) {
        
        //初始化
        [self initSharedSDK];
        
    }

    //注册通知事件
    return XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
}




AspectPatch(-, void, dealloc)
{
    XAMessageForwardDirectly(dealloc);
}


#pragma mark 自定义代码
//AspectPatch(-, BOOL,application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation)
//{
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
//    if (!result) {
//        
//    }
//    return result;
//}
//
//AspectPatch(-, BOOL,application:(UIApplication *)application handleOpenURL:(NSURL *)url)
//{
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
//    if (!result) {
//        
//    }
//    return result;
//}

@end
#undef AtAspectOfClass
#undef AtAspect
