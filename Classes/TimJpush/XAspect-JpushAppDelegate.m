//
//  XAspect-LogAppDelegate.m
//  MobileProject 抽离原本应在AppDelegate的内容（个推）
//
//  Created by wujunyang on 16/6/22.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "TimCoreAppDelegate.h"
#import "TimJpushConfigManager.h"
#import "TimCoreAppDelegate+myJpush.h"

#import <XAspect.h>
#import <JPUSHService.h>

#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>
#define AtAspect JpushAppDelegate

#define AtAspectOfClass TimCoreAppDelegate

@interface  TimCoreAppDelegate ()<JPUSHRegisterDelegate , UNUserNotificationCenterDelegate>

@end


@classPatchField(TimCoreAppDelegate)

@synthesizeNucleusPatch(Default, -, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);
@synthesizeNucleusPatch(Default, -, void, application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken);
@synthesizeNucleusPatch(Default, -, void, application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error);

@synthesizeNucleusPatch(Default, -, void, application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings);


@synthesizeNucleusPatch(Default, -, void, application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler);

///iOS 10
@synthesizeNucleusPatch(Default, -,void,  userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler );
@synthesizeNucleusPatch(Default, -, void,  userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler );


///iOS 9
@synthesizeNucleusPatch(Default, -,void,  application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler );


@synthesizeNucleusPatch(Default,-,void, dealloc);

/** app 启动过程 **/
AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    
    if ([TimJpushConfigManager sharedInstance].enableJpush) {
        NSLog(@"成功推送模块");

        //个推初始化
        [self initLoadJpush:launchOptions];
        
        // app 没有启动时,通过远程通知启动APP,
        [self receiveNotificationByLaunchingOptions:launchOptions];
        
    }
    
    //注册个推通知事件
    return XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
}

/** 远程通知注册成功委托 */
AspectPatch(-, void, application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken)
{
    
    NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([TimJpushConfigManager sharedInstance].enableJpush) {
        [JPUSHService registerDeviceToken:deviceToken];
        
    }
    
    [self receiveDeviceTokenHandleing:myToken];
    
    NSLog(@"\n>>>[DeviceToken值]:%@\n\n", myToken);
    
    return XAMessageForward(application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken);
}

/** 远程通知注册失败委托 */
AspectPatch(-, void, application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error){
    
    if ([TimJpushConfigManager sharedInstance].enableJpush) {
        [JPUSHService registerDeviceToken:nil];
        
    }
    
    NSLog(@"\n>>>[DeviceToken失败]:%@\n\n", error.description);
    
    return XAMessageForward(application:application didFailToRegisterForRemoteNotificationsWithError:error);
}


#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用

/** 已登记用户通知 */
AspectPatch(-, void, application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings)
{
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
    
    return XAMessageForward(application:application didRegisterUserNotificationSettings:notificationSettings);
}

///ios9 app 启动时候的推送动作  , 后台收到通知打开的动作
AspectPatch(-, void,application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler)
{
    //处理applicationIconBadgeNumber-1
    [self handlePushMessage:userInfo notification:nil];
    [JPUSHService handleRemoteNotification:userInfo];
    
    //除了个推还要处理走苹果的信息放在body里面
    if (userInfo) {
        static NSString *pre_j_msgid ;

        ///过滤潜在的推送2次的可能性
        
        NSString *_j_msgid = [userInfo objectForKey:@"_j_msgid"];
        if([_j_msgid isKindOfClass:[NSNumber class]]){
            ///过滤 number 类型
            _j_msgid = [(NSNumber *)_j_msgid stringValue];
        }
        
        NSLog(@"_j_msgid 为 %@  --- pre_j_msgid = %@ ", _j_msgid,pre_j_msgid);

        if( _j_msgid == nil ){
            
            NSLog(@"_j_msgid 为 nil");
            
            [self receiveRemoteMessageHandleing:userInfo];
            
        }else{
            NSLog(@"_j_msgid 不为 nil");
            BOOL flag = [pre_j_msgid isEqualToString:_j_msgid];
            
            if( NO == flag ){
                NSLog(@"_j_msgid 和前一个 msgid 不一样");
                
                [self receiveRemoteMessageHandleing:userInfo];
                
            }else{
                NSLog(@"_j_msgid 和前一个 msgid == 一样");
                
            }
        }
        
        ////保存当前 msgid 为前一个 msgid
        pre_j_msgid = _j_msgid;

    }
    // 处理APN
    //NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    return XAMessageForward(application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler);
    
}

#pragma mark - 用户通知(推送)回调 _IOS 10.0以上使用

AspectPatch (-, void, userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions opt))completionHandler)
{
    
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    [self receiveRemoteMessageHandleing:userInfo];
    
    [JPUSHService handleRemoteNotification:userInfo];
    
    return XAMessageForward(userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler);
    
}

AspectPatch( - , void, userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler )
{
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    [self receiveRemoteMessageHandleing:userInfo];

    [JPUSHService handleRemoteNotification:userInfo];
    
    return XAMessageForward(userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler );

}

///IOS9
AspectPatch( - , void, application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler )
{
    
//    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self receiveRemoteMessageHandleing:userInfo];
    
    return XAMessageForward(application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler );
    
}





AspectPatch(-, void, dealloc)
{
    XAMessageForwardDirectly(dealloc);
}


#pragma mark - JpushSdkDelegate

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler
{
    
    [self userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {
        completionHandler(options);
    }];
    
}
/*
 * @brief handle UserNotifications.framework [didReceiveNotificationResponse:withCompletionHandler:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param response 通知响应对象
 * @param completionHandler
 */
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    [self userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{
        completionHandler();
    }];
}




// 处理推送消息
- (void)handlePushMessage:(NSDictionary *)dict notification:(UILocalNotification *)localNotification {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber != 0) {
        if (localNotification) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
    }
    else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}



#pragma mark 自定义关于推送的内容
///初始化推送数据
-(void)initLoadJpush:(NSDictionary *)launchOptions
{
    
    // 注册APNS
    [self registerUserNotification];
   
   
    [JPUSHService registerForRemoteNotificationConfig:nil delegate:self];


    [JPUSHService setupWithOption:launchOptions
                           appKey:[TimJpushConfigManager sharedInstance].pushAppKey
                          channel:nil
                 apsForProduction:[TimJpushConfigManager sharedInstance].apsForProduction
            advertisingIdentifier:[ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString
     ];
    
    

    
}



#pragma mark - 用户通知(推送) _自定义方法

/** 注册用户通知 */
- (void)registerUserNotification {
    
    /*
     注册通知(推送)
     申请App需要接受来自服务商提供推送消息
     */
    
    ///设置 action
    if([[[UIDevice currentDevice]systemVersion]floatValue]>= 10.0 ){
        [self setUpCategoryForIos10];
        
    }else if ([[[UIDevice currentDevice]systemVersion]floatValue]>= 8.0){
        [self setUpCategoryForIos8_9];
        
    }else if ([[[UIDevice currentDevice]systemVersion]floatValue]>= 7.0){
        [self setUpCategoryForIOS7];
        
    }
    
}




/** 自定义：APP被“推送”启动时处理推送消息处理（APP 未启动--》启动）*/
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions)
        return;
    
    /*
     通过“远程推送”启动APP
     UIApplicationLaunchOptionsRemoteNotificationKey 远程推送Key
     */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
//        SHOWAlertMSG([userInfo mj_JSONString]);
//        NSLog(@"\n>>>[Launching RemoteNotification]:%@", userInfo);
        
        [self receiveNotificationByLaunchingOptionsUserInfo:userInfo];
        
    }
    
}


#pragma mark 自定义代码


@end
#undef AtAspectOfClass
#undef AtAspect
