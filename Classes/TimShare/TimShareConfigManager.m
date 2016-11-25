//
//  jiaGTConfigManager.m
//  Pods
//
//  Created by wujunyang on 16/7/7.
//
//

#import "TimShareConfigManager.h"

@implementation TimShareConfigManager

+ (TimShareConfigManager *)sharedInstance
{
    static TimShareConfigManager* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TimShareConfigManager new];
        instance.enableShare = YES;
        
    });

    return instance;
}

- (void)setPlaform:(JiaSocialPlatConfigType)platformType
            appKey:(NSString *)appKey
         appSecret:(NSString *)appSecret
       redirectURL:(NSString *)redirectURL
{
    switch (platformType) {
        case JiaSocialPlatConfigType_Sina:
            self.jiaSocialPlatConfigType_Sina_AppKey=appKey;
            self.jiaSocialPlatConfigType_Sina_AppSecret=appSecret;
            self.jiaSocialPlatConfigType_Sina_RedirectURL=redirectURL;
            break;
        case JiaSocialPlatConfigType_Wechat:
            self.jiaSocialPlatConfigType_Wechat_AppKey=appKey;
            self.jiaSocialPlatConfigType_Wechat_AppSecret=appSecret;
            self.jiaSocialPlatConfigType_Wechat_RedirectURL=redirectURL;
            break;
        case JiaSocialPlatConfigType_Tencent:
            self.jiaSocialPlatConfigType_Tencent_AppKey=appKey;
            self.jiaSocialPlatConfigType_Tencent_AppSecret=appSecret;
            self.jiaSocialPlatConfigType_Tencent_RedirectURL=redirectURL;
            break;
        default:
            break;
    }
}

@end
