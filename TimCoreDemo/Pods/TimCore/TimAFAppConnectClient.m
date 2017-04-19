//
//  AFAppConnectClient.m
//  CarMaintenance
//
//  Created by S.K. on 15-1-5.
//  Copyright (c) 2015年 S.K. All rights reserved.
//

#import "TimAFAppConnectClient.h"



#define DLog( s, ... ) NSLog( @"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )


@interface TimAFAppConnectClient ()
@property (strong,nonatomic) NSMutableDictionary * allShareClient ;

@end

@implementation TimAFAppConnectClient

static NSString *baseUrl ;
+(void)setBaseUrl:(NSString*)url
{
    baseUrl = url;
    
}


#pragma mark- 单例对象，实例话

+(TimAFAppConnectClient *)sharedClientFor:(NSString *)baseUrl
{
    if(baseUrl.length == 0)
    {
        return nil;
    }
    
    TimAFAppConnectClient *allShare = [TimAFAppConnectClient sharedClient];
    
    __block  TimAFAppConnectClient *share = [allShare.allShareClient objectForKey:baseUrl];
    
    if (share == nil) {
        
        static TimAFAppConnectClient *shareNetworkClient22;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            
            shareNetworkClient22 = [[TimAFAppConnectClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
            shareNetworkClient22.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            shareNetworkClient22.responseSerializer = [AFJSONResponseSerializer serializer];
            
            shareNetworkClient22.responseSerializer.acceptableContentTypes =[NSSet setWithArray:@[@"text/html",@"text/plain",@"application/json"]];
            
            //        shareNetworkClient.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD"]];
            
            
            //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate ];
            //
            //        securityPolicy.pinnedCertificates = [NSSet setWithObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"www.taoqian123.com" ofType:@"cer"]]];
            ////        securityPolicy.validatesDomainName = NO;
            ////        securityPolicy.allowInvalidCertificates = YES;
            ////
            //        shareNetworkClient.securityPolicy = securityPolicy;
            
            
            share = shareNetworkClient22;
            shareNetworkClient22 = nil;
            
            [allShare.allShareClient setObject:share forKey:baseUrl];
            
        });
        
        
        
    }
    
    return share;
    
}

+ (TimAFAppConnectClient *)sharedClient
{
    static TimAFAppConnectClient *shareNetworkClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        shareNetworkClient = [[TimAFAppConnectClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        shareNetworkClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        shareNetworkClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
        shareNetworkClient.responseSerializer.acceptableContentTypes =[NSSet setWithArray:@[@"text/html",@"text/plain",@"application/json"]];
        
        //        shareNetworkClient.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD"]];
        
        
        //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate ];
        //
        //        securityPolicy.pinnedCertificates = [NSSet setWithObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"www.taoqian123.com" ofType:@"cer"]]];
        ////        securityPolicy.validatesDomainName = NO;
        ////        securityPolicy.allowInvalidCertificates = YES;
        ////
        //        shareNetworkClient.securityPolicy = securityPolicy;
        
        
        
        [shareNetworkClient setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];
        
        
    });
    
    return shareNetworkClient;
}

- (void)cancelRequestsWithPath:(NSString *)path
{
    //    for (NSOperation *operation in [self.operationQueue operations]) {
    ////        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
    ////            continue;
    ////        }
    ////
    ////        BOOL hasMatchingPath = [[[[(AFHTTPRequestOperation *)operation request] URL] path] isEqual:path];
    ////
    ////        if (hasMatchingPath) {
    ////            [operation cancel];
    ////        }
    //    }
}


/**
 *  设置 几个基本解析参数
 *
 *  @param sucessCode    成功返回的状态码
 *  @param statusCodeKey     状态码 KEY
 *  @param msgKey  返回 msg 的 key
 *  @param responseDataKey   返回内容的 key
 */
-(void)setSucessCode:(NSInteger)sucessCode statusCodeKey:(NSString *_Nonnull)statusCodeKey msgKey:(NSString *_Nonnull)msgKey responseDataKey:(NSString * _Nonnull)responseDataKey
{
    _sucessCode = sucessCode;
    
    _statusCodeKey = statusCodeKey;
    _msgKey = msgKey;
    _responseDataKey = responseDataKey;
    
    
}



#pragma mark - GET
/**
 *  GET请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skGetWithMethodName:(NSString *)methodName
                      param:(NSDictionary *)param
               successBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                failedBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock
{
    [self skGetWithMethodName:methodName
                        param:param
                checkNullData:YES
                 successBlock:successBlock
                  failedBlock:failedBlock];
}


/**
 *  GET请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param checkNullData 检查data是否为空
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skGetWithMethodName:(NSString *)methodName
                      param:(NSDictionary *)param
              checkNullData:(BOOL)checkNullData
               successBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                failedBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:param];
    //    [mParam setObject:CarApiVersion forKey:@"version"];
    
    [self GET:methodName parameters:mParam progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (!responseObject) {
            if (failedBlock) {
                failedBlock(task, nil, SKErrorMsgTypeNoData, nil);
            }
        }
        else {
            NSData *data = (NSData *)responseObject;
            NSDictionary *jsonDic;
            //            = [data objectToDictionary];
            jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSString *code = [jsonDic objectForKey:_statusCodeKey];
            
            //成功
            if (code && [code integerValue] == _sucessCode ) {
                if (checkNullData) {
                    id dataObj = [jsonDic objectForKey:_responseDataKey];
                    
                    //数据为空
                    if(!dataObj || (NSNull *)dataObj == [NSNull null]){
                        if (failedBlock) {
                            failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                        }
                    }
                    else{
                        if (successBlock) {
                            successBlock(task,jsonDic);
                        }
                    }
                }
                else{
                    if (successBlock) {
                        successBlock(task,jsonDic);
                    }
                }
            }
            else {
                if (failedBlock) {
                    failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //取消请求的，不走failedBlock
        if ([[error description]  rangeOfString:@"cancelled"].location == NSNotFound  && failedBlock) {
            failedBlock(task,nil,SKErrorMsgTypeError,error);
        }
    }];
    
    
    return;

    
}

#pragma mark - POST
/**
 *  POST请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skPostWithMethodName:(NSString *)methodName
                       param:(NSDictionary *)param
                successBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))  successBlock
                 failedBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock
{
    [self skPostWithMethodName:methodName
                         param:param
                 checkNullData:YES
                  successBlock:successBlock
                   failedBlock:failedBlock];
}


/**
 *  POST请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param checkNullData 检查data是否为空
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skPostWithMethodName:(NSString *)methodName
                       param:(NSDictionary *)param
               checkNullData:(BOOL)checkNullData
                successBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:param];
    mParam  =[self addBaseInfo:mParam];
    
    [self POST:methodName parameters:mParam progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!responseObject) {
            if (failedBlock) {
                failedBlock(task, nil, SKErrorMsgTypeNoData, nil);
            }
        }
        else {
            
            NSData *data = nil;
            NSDictionary *jsonDic = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                jsonDic = (NSDictionary *)responseObject;
                
            }else{
                data = (NSData *)responseObject;
                //                jsonDic = [data objectToDictionary];
                jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
            }
            
            //            DLog(@"jsonDic:%@",jsonDic);
            
            NSString *code = [jsonDic objectForKey:_statusCodeKey];
            
            //成功
            if (code && [code integerValue] == _sucessCode ) {
                if (checkNullData) {
                    id dataObj = [jsonDic objectForKey:_responseDataKey];
                    
                    //数据为空
                    if(!dataObj || (NSNull *)dataObj == [NSNull null]){
                        if (failedBlock) {
                            failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                        }
                    }
                    else{
                        if (successBlock) {
                            successBlock(task,jsonDic);
                        }
                    }
                }
                else{
                    if (successBlock) {
                        successBlock(task,jsonDic);
                    }
                }
            }
            else {
                if (failedBlock) {
                    //                    failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                    
                    NSString *msg = [jsonDic objectForKey:_msgKey];
                    NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                    
                    failedBlock(task,jsonDic,SKErrorMsgTypeNoData,[NSError errorWithDomain:msg code:[code intValue] userInfo:errorMessage]);
                    
                    
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //取消请求的，不走failedBlock
        if ([[error description]  rangeOfString:@"cancelled"].location == NSNotFound  && failedBlock) {
            failedBlock(task,nil,SKErrorMsgTypeError,error);
        }else if(failedBlock) {
            failedBlock(task,nil,SKErrorMsgTypeError,error);
            
        }
    }];
    
    
}

- (void)skPostWithMethodName:(NSString *_Nonnull)methodName
                       param:(NSDictionary * _Nullable )param
   constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                    progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
               checkNullData:(BOOL)checkNullData
                successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:param];
    mParam  =[self addBaseInfo:mParam];
    
    [self POST:methodName parameters:mParam constructingBodyWithBlock:block progress:uploadProgress
     
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           if (!responseObject) {
               if (failedBlock) {
                   failedBlock(task, nil, SKErrorMsgTypeNoData, nil);
               }
           }
           else {
               
               NSData *data = nil;
               NSDictionary *jsonDic = nil;
               if ([responseObject isKindOfClass:[NSDictionary class]]) {
                   jsonDic = (NSDictionary *)responseObject;
                   
               }else{
                   data = (NSData *)responseObject;
                   //                   jsonDic = [data objectToDictionary];
                   jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                   
               }
               
               //               DLog(@"jsonDic:%@",jsonDic);
               
               NSString *code = [jsonDic objectForKey:_statusCodeKey];
               
               //成功
               if (code && [code integerValue] == _sucessCode ) {
                   if (checkNullData) {
                       id dataObj = [jsonDic objectForKey:_responseDataKey];
                       
                       //数据为空
                       if(!dataObj || (NSNull *)dataObj == [NSNull null]){
                           if (failedBlock) {
                               failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                           }
                       }
                       else{
                           if (successBlock) {
                               successBlock(task,jsonDic);
                           }
                       }
                   }
                   else{
                       if (successBlock) {
                           successBlock(task,jsonDic);
                       }
                   }
               }
               else {
                   if (failedBlock) {
                       NSString *msg = [jsonDic objectForKey:_msgKey];
                       NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                       
                       failedBlock(task,jsonDic,SKErrorMsgTypeNoData,[NSError errorWithDomain:msg code:[code intValue] userInfo:errorMessage]);
                       //                       failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                       
                   }
               }
           }
           
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           //取消请求的，不走failedBlock
           if ([[error description]  rangeOfString:@"cancelled"].location == NSNotFound  && failedBlock) {
               failedBlock(task,nil,SKErrorMsgTypeError,error);
           }else if(failedBlock) {
               failedBlock(task,nil,SKErrorMsgTypeError,error);
               
           }
       }];
    
    
    
}



-(NSMutableDictionary*)addBaseInfo:(NSDictionary*)info
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    return mParam;
}
@end
