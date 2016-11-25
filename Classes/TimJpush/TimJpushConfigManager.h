//
//  jiaGTConfigManager.h
//  Pods
//
//  Created by wujunyang on 16/7/7.
//
//

#import <Foundation/Foundation.h>

@interface TimJpushConfigManager : NSObject

+ (TimJpushConfigManager *)sharedInstance;

//push配置
//@property (strong, nonatomic) NSString *pushAppId;
@property (strong, nonatomic) NSString *pushAppKey;
//@property (strong, nonatomic) NSString *pushAppSecret;
@property (assign, nonatomic) BOOL apsForProduction;


@property (assign, nonatomic) BOOL enableJpush;


@end
