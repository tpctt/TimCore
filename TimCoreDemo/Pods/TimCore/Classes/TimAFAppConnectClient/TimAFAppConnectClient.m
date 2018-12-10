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
@property (strong,nonatomic) NSCache * allShareClient ;
@property (strong,nonatomic) NSCache *netStateCache;

@end

@implementation TimAFAppConnectClient

static NSString *baseUrl ;
+(void)setBaseUrl:(NSString*)url
{
    baseUrl = url;
    
}


#pragma mark- 单例对象，实例话
+(TimAFAppConnectClient *)appConnectClientWith:(NSString *)baseUrl
{
    TimAFAppConnectClient * shareNetworkClient22 = [[TimAFAppConnectClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    shareNetworkClient22.requestSerializer = [AFJSONRequestSerializer serializer];

    
    shareNetworkClient22.responseSerializer = [AFJSONResponseSerializer serializer];
    
    shareNetworkClient22.responseSerializer.acceptableContentTypes =[NSSet setWithArray:@[@"text/html",@"text/plain",@"application/json"]];
    
    shareNetworkClient22.netStateCache = [NSCache new];
    shareNetworkClient22.allShareClient = [NSCache new];

    shareNetworkClient22.HTTPMEHHOD = @"POST";
    
    
    //        shareNetworkClient.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD"]];
    
    
    //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate ];
    //
    //        securityPolicy.pinnedCertificates = [NSSet setWithObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"]]];
    ////        securityPolicy.validatesDomainName = NO;
    ////        securityPolicy.allowInvalidCertificates = YES;
    ////
    //        shareNetworkClient.securityPolicy = securityPolicy;
    
    
    
    return shareNetworkClient22;
    
}

+(TimAFAppConnectClient *)sharedClientFor:(NSString *)baseUrl
{
    if(baseUrl.length == 0)
    {
        return nil;
    }
    
    TimAFAppConnectClient *allShare = [TimAFAppConnectClient sharedClient];
    
    __block  TimAFAppConnectClient *share = [allShare.allShareClient objectForKey:baseUrl];
    
    if (share == nil) {
        share = [TimAFAppConnectClient appConnectClientWith:baseUrl];
        
        [allShare.allShareClient setObject:share forKey:baseUrl];
        
    }
    
    return share;
    
}

+ (TimAFAppConnectClient *)sharedClient
{
    static TimAFAppConnectClient *shareNetworkClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        shareNetworkClient = [TimAFAppConnectClient appConnectClientWith:baseUrl];
        
        
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
-(void)setSucessCode:(NSString *)sucessCode statusCodeKey:(NSString *_Nonnull)statusCodeKey msgKey:(NSString *_Nonnull)msgKey responseDataKey:(NSString * _Nonnull)responseDataKey
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
            if ([code isKindOfClass:[NSNumber class]]) {
                code = [(NSNumber *)code stringValue];
            }
            //成功
            if (code && [code isEqualToString: _sucessCode] ) {
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
                    msg = msg?:@"";
                    
                    NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                    
                    failedBlock(task,responseObject,SKErrorMsgTypeNoData,[NSError errorWithDomain:msg code:[code intValue] userInfo:errorMessage]);
                    //                       failedBlock(task,jsonDic,SKErrorMsgTypeNoData,nil);
                    
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
            if ([code isKindOfClass:[NSNumber class]]) {
                code = [(NSNumber *)code stringValue];
            }
            //成功
            if (code && [code isEqualToString: _sucessCode]  ) {
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
               if ([code isKindOfClass:[NSNumber class]]) {
                   code = [(NSNumber *)code stringValue];
               }
               //成功
               if (code && [code isEqualToString: _sucessCode] ) {
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
                       msg = msg?:@"";
                       
                       NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                       
                       failedBlock(task,responseObject,SKErrorMsgTypeNoData,[NSError errorWithDomain:msg code:[code intValue] userInfo:errorMessage]);
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

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self POST:URLString parameters:parameters constructingBodyWithBlock:nil progress:uploadProgress success:success failure:failure];
    
}


- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //
    //    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    //    NSURLCredential *credential = nil;
    //
    //    disposition = NSURLSessionAuthChallengeUseCredential;
    //    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    //    completionHandler(disposition, credential);
    //    return;
    
    
    NSURLSessionTask *task = nil;
    
    [self URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    
}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    /*
     * 获取原始域名信息。
     */
    BOOL useDNS = NO;
    NSString *host = [[task.originalRequest allHTTPHeaderFields] objectForKey:@"host"];
    if(!host){
        host = self.baseURL.host;
    }else{
        useDNS = YES;
    }
    
    if (!host) {
        host = task.originalRequest.URL.host;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (useDNS == NO) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
                disposition = NSURLSessionAuthChallengeUseCredential;
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }else{
            if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
                disposition = NSURLSessionAuthChallengeUseCredential;
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }
        
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition, credential);
}


- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block

                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return  [self POST:URLString parameters:parameters constructingBodyWithBlock:block
          allowHTTPDNS:YES
              progress:uploadProgress success:success failure:failure];
    
}
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                  allowHTTPDNS:(BOOL)allowHTTPDNS
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    NSString *requestWithMethod = self.HTTPMEHHOD;
    
    if ([self.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]] ||
        [self.requestSerializer.HTTPMethodsEncodingParametersInURI containsObject:[requestWithMethod uppercaseString]] )
    {
        request = [self.requestSerializer requestWithMethod:requestWithMethod URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    }else{
        request =  [self.requestSerializer multipartFormRequestWithMethod:requestWithMethod URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    }

    
    NSNumber *hostNum = [self.netStateCache objectForKey:self.baseURL.host];
    //    hostNum = @1;
    if(hostNum && [hostNum integerValue] > 2 && allowHTTPDNS ){
        ///dns
        NSURL *url = request.URL;
        NSString *originalUrl = url.absoluteString;
        
        // 同步接口获取IP
        NSString* ip = [self.dnsTable objectForKey:url.host];
        //    ip = @"120.27.142.86";
        
        if (ip) {
            // 通过HTTPDNS获取IP成功，进行URL替换和HOST头设置
            NSRange hostFirstRange = [originalUrl rangeOfString: url.host];
            if (NSNotFound != hostFirstRange.location) {
                NSString* newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
                //            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newUrl]];
                request.URL =[NSURL URLWithString:newUrl];
                // 设置请求HOST字段
                [request setValue:url.host forHTTPHeaderField:@"host"];
            }
        }
        
    }
    
    if (self.addHTTPHeaderFields) {
        NSMutableDictionary *headerFields =[request.allHTTPHeaderFields mutableCopy];
        [headerFields addEntriesFromDictionary:self.addHTTPHeaderFields];
        
        request.allHTTPHeaderFields = headerFields;
        
    }
    request.HTTPMethod = self.HTTPMEHHOD;
    
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if(error){
                
                if (allowHTTPDNS == NO) {
                    if (failure) {
                        failure(task, error);
                    }
                    return ;
                }
                
                
                
                if (error.code <= -1200 && error.code >= -2000) {
                    ///此服务器的证书无效。您可能正在连接到一个伪装成“xxx”的服务器，这会威胁到您的机密信息的安全。
                    if (failure) {
                        failure(task, error);
                    }
                    return ;
                }
                
                
                
                
                
                NSNumber *hostNum = [self.netStateCache objectForKey:self.baseURL.host];
                if(hostNum )
                {
                    hostNum = @([hostNum integerValue]+1);
                }else{
                    hostNum = @1;
                }
                
                [self.netStateCache setObject:hostNum forKey:self.baseURL.host];
                
                ///失败3次就不 repeat 网络请求
                if(hostNum.integerValue > 3) {
                    if (failure) {
                        failure(task, error);
                    }
                }else{
                    if([self.baseURL.host isEqualToString:task.originalRequest.URL.host] ){
                        //REPET
                        
                        [self POST:URLString parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure];
                        
                    }else{
                        if (failure) {
                            failure(task, error);
                        }
                    }
                }
                
                
                
                
            }else{
                if (failure) {
                    failure(task, error);
                }
            }
            
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}



-(NSMutableDictionary*)addBaseInfo:(NSDictionary*)info
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    return mParam;
}
@end
