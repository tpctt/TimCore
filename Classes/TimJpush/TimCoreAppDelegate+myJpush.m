//
//  jiaAppDelegate+myGt.m
//  Pods
//
//  Created by wujunyang on 16/7/7.
//
//

#import "TimCoreAppDelegate+myJpush.h"
#import "TimJpushConfigManager.h"
#import <objc/runtime.h>

@implementation TimCoreAppDelegate (myJpush)



#pragma mark  application Delegate -PUSH

 

///通知打开 app, 参数是 dic
-(void)receiveNotificationByLaunchingOptionsUserInfo:(NSDictionary*)dic{

}

-(void)dealPushDict:(NSDictionary *)userInfo  applicationState:(UIApplicationState)state catg:(NSString *)catg action:(NSString *)action
{
    
    if (self.pushBlock) {
    
        self.pushBlock(userInfo,state);
    
    }
    
    
}

#pragma mark 基本功能
//处理个推本地通知，判断是否存在gtNotification方法
- (void)localMessageHandleing:(NSDictionary *)dic{}
//处理苹果远程通知，判断是否存在receiveRemoteNotification方法
- (void)receiveRemoteMessageHandleing:(NSDictionary *)dic
//                                 catg:(NSString *)catg action:(NSString *)acti
{
//    UIApplicationStateActive,
//    UIApplicationStateInactive,
//    UIApplicationStateBackground
//    SHOWAlertMSG(@([UIApplication sharedApplication].applicationState).stringValue);
    
    [self dealPushDict:dic applicationState:[UIApplication sharedApplication].applicationState catg:nil action:nil];
    
}
//获得deviceToken
-(void)receiveDeviceTokenHandleing:(NSString *)deviceToken{
    
    self.deviceToken = deviceToken;
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        NSLog(@"resCode : %d,registrationID: %@",resCode,registrationID);
        self.registrationID = registrationID;
        
    }];
    
    
}


#pragma mark JPUSHRegisterDelegate
/*
 * @brief handle UserNotifications.framework [willPresentNotification:withCompletionHandler:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param notification 前台得到的的通知对象
 * @param completionHandler 该callback中的options 请使用UNNotificationPresentationOptions
 */
//- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler
//{
//   
//    [self userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {
//        completionHandler(options);
//    }];
//    
//}
///*
// * @brief handle UserNotifications.framework [didReceiveNotificationResponse:withCompletionHandler:]
// * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
// * @param response 通知响应对象
// * @param completionHandler
// */
//- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
//{
//    [self userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{
//        completionHandler();
//    }];
//}

#pragma mark 注册 push

- (void)setUpCategoryForIos10
{
    ///IOS10
    
    ///openUrl
    UNNotificationCategory *category_openUrl;
    {
        
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"openUrlAct" title:@"进入页面" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"cancelAct" title:@"忽略" options:UNNotificationActionOptionDestructive];
        
        category_openUrl = [UNNotificationCategory categoryWithIdentifier:@"openUrl" actions:@[ action1,action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
        
        
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
    [center setNotificationCategories:[NSSet setWithObjects: category_openUrl  , nil]];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
}
-(void)setUpCategoryForIos8_9
{
    ///IOS8_9
    
    UIMutableUserNotificationAction * action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"openUrlAct";
    action1.title=@"打开";
    action1.activationMode = UIUserNotificationActivationModeForeground;
//    action1.destructive = YES;
    
    
    
    UIMutableUserNotificationAction * action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.identifier = @"cancelAct";
    action2.title=@"取消";
    action2.activationMode = UIUserNotificationActivationModeForeground;
//    action2.authenticationRequired = NO;
//    action2.destructive = NO;
//    action2.behavior = UIUserNotificationActionBehaviorTextInput;//点击按钮文字输入，是否弹出键盘
    
    //5S 5193f9fb6725fc8db26388542c1860f0061f00836d181692e0dc3e472cbe648c
    //6P da33ce6fb88eb087a3d3f66a86d17526b71a629c975d98fbebc6997487f92c17
    
    
    UIMutableUserNotificationCategory * category1 = [[UIMutableUserNotificationCategory alloc] init];
    category1.identifier = @"openUrl";
//    [category1 setActions:@[action2,action1] forContext:(UIUserNotificationActionContextDefault)];
    [category1 setActions:@[action1] forContext:(UIUserNotificationActionContextMinimal)];
    
    
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects: category1 , nil]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    
    {
        
    }
    
}

- (void)setUpCategoryForIOS7
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //     定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    
    // 注册远程通知 -根据远程通知类型
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    
#pragma clang diagnostic pop
    
    
}

#pragma mark 自定义的属性

static const void *TimCatgPushBlockKey  = &TimCatgPushBlockKey;

-(void)setPushBlock:(DealPushDataBlock)pushBlock
{
    objc_setAssociatedObject(self, TimCatgPushBlockKey, pushBlock, OBJC_ASSOCIATION_COPY_NONATOMIC  );
}
-(DealPushDataBlock)pushBlock
{
    return objc_getAssociatedObject(self, TimCatgPushBlockKey);
}

static const void *TimdeviceTokenKey  = &TimdeviceTokenKey;
-(void)setDeviceToken:(NSString *)deviceToken
{
    objc_setAssociatedObject(self, TimdeviceTokenKey, deviceToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC  );
    if(deviceToken){
        [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:@"TimCore_TimdeviceTokenKey"];
        
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimCore_TimdeviceTokenKey"];
        
    }
    [[NSUserDefaults standardUserDefaults]  synchronize];
    

}
-(NSString *)deviceToken
{
    NSString *deviceToken=  objc_getAssociatedObject(self, TimdeviceTokenKey);
    if (deviceToken==nil) {
//        缓存 token,处理 ios8 token 延迟的问题
        deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"TimCore_TimdeviceTokenKey"];
        
    }
    return deviceToken;
}


static const void *TimregistrationIDKey  = &TimregistrationIDKey;

-(void)setRegistrationID:(NSString *)registrationID
{
    objc_setAssociatedObject(self, TimregistrationIDKey, registrationID, OBJC_ASSOCIATION_RETAIN_NONATOMIC  );
    
    if(registrationID){
        [[NSUserDefaults standardUserDefaults]setObject:registrationID forKey:@"TimCore_TimregistrationIDKey"];
        
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimCore_TimregistrationIDKey"];
        
    }
    [[NSUserDefaults standardUserDefaults]  synchronize];
//
    

}
-(NSString *)registrationID
{
    NSString *registrationID = objc_getAssociatedObject(self, TimregistrationIDKey);
    if (registrationID==nil) {
//        缓存 token,处理 ios8 token 延迟的问题
        registrationID = [[NSUserDefaults standardUserDefaults]objectForKey:@"TimCore_TimregistrationIDKey"];

    }
    return registrationID;
    
}

///缓存 token,处理 ios8 token 延迟的问题
+(void)restoreTokenIfNeed
{
    
//    if ([TimCoreAppDelegate shareInstance].deviceToken==nil) {
//        
//        NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"TimCore_TimdeviceTokenKey"];
//        if(deviceToken)
//            [TimCoreAppDelegate shareInstance].deviceToken == deviceToken;
//        
//    }
//    
//    
//    if ([TimCoreAppDelegate shareInstance].registrationID==nil) {
//        
//        NSString *registrationID = [[NSUserDefaults standardUserDefaults]objectForKey:@"TimCore_TimregistrationIDKey"];
//        if(registrationID)
//            [TimCoreAppDelegate shareInstance].registrationID == registrationID;
//        
//    }
}


@end
