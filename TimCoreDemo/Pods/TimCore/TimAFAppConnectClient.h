//
//  AFAppConnectClient.h
//  CarMaintenance
//
//  Created by S.K. on 15-1-5.
//  Copyright (c) 2015年 S.K. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

//#import <AFNetworking/AFHTTPRequestOperationManager.h>



/*
 * 错误类型
 */
typedef NS_ENUM(NSUInteger, SKErrorMsgType) {
    SKErrorMsgTypeError,
    SKErrorMsgTypeNoData,
    SKErrorMsgTypeNoNotificationData,
    SKErrorMsgTypeUnkown,
};


@interface TimAFAppConnectClient : AFHTTPSessionManager
//解析的状态值
@property (assign,nonatomic,readonly)   NSInteger   sucessCode;
@property (strong,nonatomic,readonly)    NSString* _Nonnull statusCodeKey;
@property (strong,nonatomic,readonly)    NSString* _Nonnull msgKey;
@property (strong,nonatomic,readonly)    NSString* _Nonnull responseDataKey;




+(void)setBaseUrl:(NSString*_Nonnull)url __attribute__((deprecated("使用sharedClientFor:")));
+(TimAFAppConnectClient * _Nonnull )sharedClient __attribute__((deprecated("使用sharedClientFor:")));

+(TimAFAppConnectClient *)sharedClientFor:(NSString *)baseUrl;


/**
 *  设置 几个基本解析参数
 *
 *  @param sucessCode    成功返回的状态码
 *  @param statusCodeKey     状态码 KEY
 *  @param msgKey  返回 msg 的 key
 *  @param responseDataKey   返回内容的 key
 */
-(void)setSucessCode:(NSInteger)sucessCode statusCodeKey:(NSString *_Nonnull)statusCodeKey msgKey:(NSString *_Nonnull)msgKey responseDataKey:(NSString * _Nonnull)responseDataKey;



/**
 *  取消请求
 *
 *  @param path       路径
 */
- (void)cancelRequestsWithPath:(NSString *_Nonnull)path;


/**
 *  GET请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skGetWithMethodName:(NSString *_Nonnull)methodName
                      param:(NSDictionary * _Nullable )param
               successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;


/**
 *  GET请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param checkNullData 检查data是否为空
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skGetWithMethodName:(NSString *_Nonnull)methodName
                      param:(NSDictionary * _Nullable )param
              checkNullData:(BOOL)checkNullData
               successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;


/**
 *  POST请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */

- (void)skPostWithMethodName:(NSString *_Nonnull)methodName
                       param:(NSDictionary * _Nullable )param
                successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;


/**
 *  GET请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param checkNullData 检查data是否为空
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skPostWithMethodName:(NSString *_Nonnull)methodName
                       param:(NSDictionary * _Nullable )param
               checkNullData:(BOOL)checkNullData
                successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;

- (void)skPostWithMethodName:(NSString *_Nonnull)methodName
                       param:(NSDictionary * _Nullable )param
   constructingBodyWithBlock:(void (^ _Nullable )(id  <AFMultipartFormData> _Nullable formData))block
                    progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
               checkNullData:(BOOL)checkNullData
                successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;


-(NSMutableDictionary*_Nonnull)addBaseInfo:(NSDictionary* _Nullable)info;

@end
