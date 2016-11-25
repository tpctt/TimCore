//
//  3rd.m
//  taoqianbao
//
//  Created by tim on 16/11/1.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "TimCoreAppDelegate+share.h"
#import "TimShareConfigManager.h"



#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <MOBFoundation/MOBFoundation.h>




#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKConnector/ShareSDKConnector.h>


//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"
#import "WeiboSDK.h"



@interface TimCoreAppDelegate ()
///<WXApiDelegate>

@end


@implementation  TimCoreAppDelegate(share)


-(void)initSharedSDK
{
   
    {
        //打开日志
        if([TimShareConfigManager sharedInstance ].enableShare == NO)
        {
            return;
        }
        NSLog(@"成功加载友盟分享");

        if(JiaShareConfigManagerInstance.shareAppKey)
        {
            {
                [ShareSDK registerApp:JiaShareConfigManagerInstance.shareAppKey
                 
                      activePlatforms:@[
                                        @(SSDKPlatformTypeSinaWeibo),
                                        //                            @(SSDKPlatformTypeSMS),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ)]
                             onImport:^(SSDKPlatformType platformType)
                 {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]  ];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                             
                         default:
                             break;
                     }
                 }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
                 {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeSinaWeibo:
                             //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                             if(JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Sina_AppKey&&JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Sina_AppSecret)
                             {
                                 NSLog(@"分享-新浪平台已经配置");

                                 [appInfo SSDKSetupSinaWeiboByAppKey:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Sina_AppKey
                                                       appSecret:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Sina_AppSecret
                              //                                                 redirectUri:@"https://api.weibo.com/oauth2/default.html"
                                                     redirectUri:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Sina_RedirectURL
                                                        authType:SSDKAuthTypeBoth];
                             }
                           
                             break;
                         case SSDKPlatformTypeWechat:
                             if(JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Wechat_AppKey&&JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Wechat_AppSecret)
                             {
                                 NSLog(@"分享-微信平台已经配置");
                             
                                 [appInfo SSDKSetupWeChatByAppId:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Wechat_AppKey
                                                   appSecret:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Wechat_AppSecret];
                             }
                             break;
                         case SSDKPlatformTypeQQ:
                             if(JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Tencent_AppKey&&JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Tencent_AppSecret)
                             {
                                 NSLog(@"分享-qq平台已经配置");

                                 [appInfo SSDKSetupQQByAppId:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Tencent_AppKey
                                                  appKey:JiaShareConfigManagerInstance.jiaSocialPlatConfigType_Tencent_AppSecret
                                                authType:SSDKAuthTypeBoth];
                             }
                             break;
                             
                             
                         default:
                             break;
                     }
                     
                
                 }];
                
                
                
                
            }
            
         }
        
       
        
        
        
        
    }
    
    
    
    
}



-(void)shareInfo:(NSString *)title content:(NSString *)content image:(id)image  url:(NSString *)url actionSheet:(UIView *)actionSheet onShareStateChanged:(ShareResult)shareStateChangedHandler
{

  
    //    UIImage *imageUrl = nil;
//    if ([image isKindOfClass:[UIImage class]]) {
//        imageUrl = image;
//    }
//    
    
    
    //1、创建分享参数
    NSArray* imageArray ;
    if(image){
//        imageArray= @[image];
    }else{
        NSArray *CFBundleIconFiles =  [[[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"];
        
        image= [UIImage imageNamed:[CFBundleIconFiles lastObject]];
        
    }
    
    if(image){
        imageArray= @[image];
    }
    
//    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）

    //    if (imageArray)
    {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKEnableUseClientShare];
        
        [shareParams SSDKSetupShareParamsByText:content
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeAuto];
        
        
        UIImage *weiboImage = nil;
        if([image isKindOfClass:[UIImage class]]){
            weiboImage = image;
            
        }else if([image isKindOfClass:[NSString class]]){
            weiboImage =  [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];

            
        }
        
        [shareParams SSDKSetupSinaWeiboShareParamsByText:[content stringByAppendingString:url?:@""]
                                                   title:title
                                                   image:weiboImage
                                                     url:[NSURL URLWithString:url]
                                                latitude:0
                                               longitude:0
                                                objectID:nil
                                                    type:  SSDKContentTypeImage  ];
        
        
        [shareParams SSDKSetupWeChatParamsByText:content
                                           title:content
                                             url:[NSURL URLWithString:url]
                                      thumbImage:image
                                           image:image
                                    musicFileURL:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil
                                            type: SSDKContentTypeAuto
                              forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        
        
        
        NSMutableArray *activePlatforms = @[@(SSDKPlatformTypeSinaWeibo) ,@(SSDKPlatformTypeQQ) , @(SSDKPlatformSubTypeWechatSession) , @(SSDKPlatformSubTypeWechatTimeline)].mutableCopy;
        
        //添加一个自定义的平台（非必要）
//        SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem
//                                                itemWithIcon:[UIImage imageNamed:@"Icon.png"]
//                                                label:@"自定义"
//                                                
//                                                onClick:^{
//
//
//                                                }];

//        [activePlatforms addObject:item];
        
        
        
        
        //设置分享菜单栏样式（非必要）
        //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
//                [SSUIShareActionSheetStyle setActionSheetColor:[UIColor blackColor]];
//                [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor yellowColor]];
//                [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor redColor]];
//                [SSUIShareActionSheetStyle setItemNameColor:[UIColor redColor]];
        //        [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
        //        [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
        //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:[UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0]];
    
        [SSDKAuthViewStyle setCancelButtonLabelColor:[UIColor blackColor]];
        
        
        
        
        
        //2、分享（可以弹出我们的分享菜单和编辑界面）
     SSUIShareActionSheetController *sheet =     [ShareSDK showShareActionSheet:actionSheet //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:activePlatforms
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       if(state != SSDKResponseStateBegin){
                           if(state == SSDKResponseStateSuccess && [ShareSDK isClientInstalled:SSDKPlatformTypeSinaWeibo] == NO ){
//                               SHOWMSG(@"分享成功");
                           
                           }
                           
                           if(shareStateChangedHandler ) {
                               shareStateChangedHandler(state == SSDKResponseStateSuccess , error.localizedDescription);
                               return ;
                           }
                           
                           
                       }
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               
                               break;
                               
                           }
                           default:
                               break;
                       }
                   }
         ];
        
        
        
        
        //另附：设置跳过分享编辑页面，直接分享的平台。
        //        SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view
        //                                                                         items:nil
        //                                                                   shareParams:shareParams
        //                                                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        //                                                           }];
        //
        //        //删除和添加平台示例
        //        [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
        
        if([ShareSDK isClientInstalled:SSDKPlatformTypeSinaWeibo] == YES){
            [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
            
        }
        
        
        
    }
}
//
//- (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//    
//}
//-(BOOL)application:(UIApplication*)app openURL:(NSURL*)url options:(NSDictionary<NSString *,id> *)options
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    
//    return  [WXApi handleOpenURL:url delegate:self];
//    
//}
//

-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                //                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                //                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
        
    }  
}
@end
