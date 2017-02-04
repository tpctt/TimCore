//
//  BaseViewModel.m
//  taoqianbao
//
//  Created by tim on 16/9/6.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "TimBaseListViewModel.h"
#import <TMCache.h>
#import <TimSearchItemForObjectProtocol.h>
//#import <SVProgressHUD.h>

#import <CoreSpotlight/CoreSpotlight.h>
// #import "AppDelegate.h"

const NSString *TimCachedata_prefix = @"TimCachedata_prefix";

@implementation TimBaseViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        [self initialize];
        [self initNetError];
        
        
    }
    return self;
}

-(void)dealloc
{
    
    NSLog(@"dealloc %@--%@", NSStringFromClass(self.class),self.path );
    
}

-(void)initNetError
{
//    @weakify(self);
    [self.command.errors subscribeNext:^(NSError *error) {
     //   @strongify(self);

        if (error.code == -2 ) {
            ///token 失效
//            [[NSNotificationCenter defaultCenter]postNotificationName:TimNeedLoginNotification object:error ];
            
           
        }
        
    }];
     
    
}
#pragma mark cache
-(void)didGetData:(id  _Nullable )json subscriber:(id<RACSubscriber>) subscriber isCache:(BOOL)isCache
{
    NSDictionary *dict = json;
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSInteger flag = [dict[_appConnectClient.statusCodeKey] integerValue];
    NSString *msg = dict[_appConnectClient.msgKey] ;
    self.msg = msg;
    
    
    if (flag != _appConnectClient.sucessCode ) {
        
        [subscriber sendError:[NSError errorWithDomain:@"com.taoqian123" code:flag userInfo:@{NSLocalizedDescriptionKey:msg }]];
        //                    [subscriber sendCompleted];
        return;
    }
    
    dict = dict[_appConnectClient.responseDataKey];
    self.output = dict;
    
    
    if(self.outputBlock){
        
        [subscriber  sendNext:self.outputBlock(dict)];
        
        
    }else{
        
        [subscriber sendNext:dict];
        
    }
    [self dealArrayToSearch:[self getSearchArray]];

    if(isCache == NO){
        [subscriber sendCompleted];
    }
    

}
-(void)saveJson:(id  _Nullable )json
{
    
    if(json && self.allowCacheData == YES ){

#pragma warning warning
        
        //部分 json 数据不能保存,... warning ,NULL
//        [[NSUserDefaults standardUserDefaults]setObject:json forKey:[self getCacheKey]];
//        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[TMCache sharedCache]setObject:json forKey:[self getCacheKey]];
        
    }else{
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self getCacheKey]];
        [[TMCache sharedCache] removeObjectForKey:[self getCacheKey]];

    }
    
}

-(void)getCacheData:(id<RACSubscriber>) subscriber
{
    
//    id tempCacheData = [[NSUserDefaults standardUserDefaults] objectForKey:[self getCacheKey]];
    
    if(self.allowCacheData){
        id tempCacheData =  [[TMCache sharedCache] objectForKey:[self getCacheKey]];

        if(tempCacheData ){
            [self didGetData:tempCacheData subscriber:subscriber isCache:YES];
            
        }
        
    }
    
    
}


-(NSString *)getCacheKey{
    NSMutableDictionary *postPara = self.vmPara.mutableCopy;
    [postPara removeObjectsForKeys:[[[self class] addBaseInfo:nil forWeb:NO] allKeys]];
    
    
    return [[TimCachedata_prefix stringByAppendingPathComponent:@"request"] stringByAppendingPathComponent: [self.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",postPara]]];
    
    
}


#pragma mark 实现过程
- (void)initialize{
    @weakify(self);

    _appConnectClient =   [TimAFAppConnectClient sharedClient];

    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        self.vmPara = @{}.mutableCopy;
        
        RACSignal *signal =   [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);

            self.vmPara = [[self class]addBaseInfo:self.vmPara forWeb:NO];
            if ( self.inputBlock) {
                self.vmPara = self.inputBlock([self.vmPara mutableCopy]);
            }
            
            NSAssert(self.path.length  , ([NSString stringWithFormat:@"%@ %@ path 为空",self ,self.path ]));
            
            
            if ( ! self.path.length) {
                
                return [RACDisposable disposableWithBlock:^{}];
                
            }
            
            
            
            [self getCacheData:subscriber];
            
            [self.appConnectClient skPostWithMethodName:self.path param:self.vmPara constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nullable formData) {

                @strongify(self);

                  if (self.formDataInputBlock) {
                      self.formDataInputBlock(formData);
                  }
                  
                  
              } progress:nil checkNullData: NO successBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
                
                  @strongify(self);

                  [self didGetData:json subscriber:subscriber isCache:NO];
                  [self saveJson:json];
                  
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json, SKErrorMsgType errorType, NSError * _Nullable error) {
                self.output = json;

                [subscriber sendError:error];
//                [subscriber sendCompleted];

            }];
            
            return [RACDisposable disposableWithBlock:^{
                
            }];
            
        }]setNameWithFormat:@"vm_skPostWithMethodName-%@",self.path];
        
        
        return signal;
        
        
        
    }];
    
    
    
}



///
+(NSMutableDictionary*)addBaseInfo:(NSDictionary*)info forWeb:(BOOL)forWeb
{
    NSMutableDictionary *mParam = [[NSMutableDictionary alloc] initWithDictionary:info];
    {
        
//        if ([TimUserObject isLoged] && [TimUserObject sharedInstance].access_token.length  ) {
//            [mParam setObject:[TimUserObject sharedInstance].access_token forKey:@"access_token"];
//            
//        }
//        if([Config sharedInstance].cityModel && [Config sharedInstance].cityModel .id ){
//            [mParam setObject:[Config sharedInstance].cityModel .id  forKey:@"city_id"];
//
//        }
//        //        front //前端类型 0=pc 1=wap 2=ios 3=android
//        [mParam setObject:@( 2 ).stringValue forKey:@"front"];
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString*  appVersion =[NSString stringWithFormat:@"%@",  [infoDict objectForKey:@"CFBundleShortVersionString"]  ];
        ///现在的app的版本
        [mParam setObject:appVersion forKey:@"version"];

        
//        if([AppDelegate shareInstance].registrationID){
//            [mParam setObject:[AppDelegate shareInstance].registrationID forKey:@"registration_id"];
//
//        }
//        if([AppDelegate shareInstance].deviceToken){
//            [mParam setObject:[AppDelegate shareInstance].deviceToken forKey:@"deviceToken"];
//            
//        }
        
        
        ///debug  使用,需要在一次正式版使用
//        [mParam setObject:DEBUG?@"1":@"0" forKey:@"f"];
#if DEBUG
//        [mParam setObject:@"1"forKey:@"if"];

#else
        ///确认发布之后执行的为这里
//        [mParam setObject:@"0" forKey:@"if"];

#endif
        
  
        
        
    }
    
    
    
    
    return mParam;
}
//

////搜索相关
-(void)dealArrayToSearch:(NSArray *)array
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        
        [self dealArrayToSearchInQueue:array];
        
    });
}
-(NSArray *)getSearchArray
{
    return nil;
}
-(void)dealArrayToSearchInQueue:(NSArray *)array
{
    if (!([UIDevice currentDevice].systemVersion.floatValue >= 9.0)) {
        return;
    }
    if (array.count <= 0 ) {
        return;
    }
    
    NSMutableArray *seachableItems = [NSMutableArray array ];
    
    for(NSObject *object in array){
        if ([object conformsToProtocol:@protocol(TimSearchItemForObjectProtocol)] && [object respondsToSelector:@selector(searchableItem)]) {
            
            NSObject<TimSearchItemForObjectProtocol > *objectProtocol = (id<TimSearchItemForObjectProtocol>)object;
            CSSearchableItem *item = [objectProtocol searchableItem];
            
            if(item){
                [seachableItems addObject:item];
            }
            
        }
    }
    
    
    CSSearchableIndex *manager = [CSSearchableIndex new];
    [manager beginIndexBatch];
    [manager indexSearchableItems:seachableItems
                completionHandler:^(NSError * __nullable error){                                                              if (error)
                        NSLog(@"%@",error.localizedDescription);
    
                }];
    [manager endIndexBatchWithClientState:[NSData new] completionHandler:^(NSError * _Nullable error) {
        
    }];
    
//    
//    [[CSSearchableIndex defaultSearchableIndex]
//     indexSearchableItems:seachableItems
//        completionHandler:^(NSError * __nullable error){                                                              if (error)
//                NSLog(@"%@",error.localizedDescription);
//                                                       
//    }];
    
}


@end



////
@implementation TimBaseListViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = 1;
    }
    return self;
}
-(RACSignal*)loadFirstPage
{
    self.page = 1;
    return  [self loadPages];
    
}
-(RACSignal*)loadNextPage
{
    self.page+=1;
    if (self.page<=0) {
        self.page = 1;
    }
    
    return [self loadPages];
    
}
-(RACSignal*)loadPages
{
    
//    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:self.para ];
//    
//    [para setObject:@(_page) forKey:@"page"];
//    
//    self.para = para;
//    
    
    return  [self.command execute:nil];
    
    
}

-(void)didGetData:(id  _Nullable )json subscriber:(id<RACSubscriber>) subscriber isCache:(BOOL)isCache
{
    
    NSDictionary *dict = json;
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSInteger flag = [dict[_appConnectClient.statusCodeKey] integerValue];
    NSString *msg = dict[_appConnectClient.msgKey] ;
    self.msg = msg;
    
    
    if (flag != _appConnectClient.sucessCode ) {
        
        [subscriber sendError:[NSError errorWithDomain:@"com.taoqian123" code:flag userInfo:@{NSLocalizedDescriptionKey:msg }]];
        //                    [subscriber sendCompleted];
        return;
    }
    
    dict = dict[_appConnectClient.responseDataKey];
    self.output = dict;
    
    
    NSArray *array = nil;
    if(self.block){
        array= self.block( dict );
    }
    if(self.outputBlock){
        [subscriber  sendNext:self.outputBlock(dict)];
    }
    
    
    NSMutableArray *mArray  =[NSMutableArray array];
    
    if(self.page <= 1){
        
    }else{
        [mArray addObjectsFromArray:self.dataArray];
    }
    
    if (array) {
        [mArray addObjectsFromArray:array];
    }
    ///避免数据为空的时候, page 一直增加
    if(array.count == 0){
        self.page --;
    }
    
    self.dataArray = mArray;
    
    [subscriber sendNext:array];
//    [self dealArrayToSearch:[self getSearchArray]];
    [self dealArrayToSearch:array];

    if(isCache == NO){
        [subscriber sendCompleted];
        
    }
    
}
- (void)initialize {
    
    self.dataArray = [NSMutableArray array];
    
    _appConnectClient =   [TimAFAppConnectClient sharedClient];

    @weakify(self)
    
    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        self.vmPara = @{}.mutableCopy;
        
        RACSignal *signal =   [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);

            ///
            NSMutableDictionary *para = [[self class] addBaseInfo:self.vmPara forWeb:NO];
            [ para setObject:@(self.page) forKey:@"page"];
            self.vmPara = para;
            
            
            
            if ( self.inputBlock) {
                self.vmPara = self.inputBlock([self.vmPara mutableCopy]);
            }
            
            
            if ( ! self.path.length) {
               return [RACDisposable disposableWithBlock:^{  }];
            }
            
            
            
            if(self.page == 1){
                ///只使用第一页缓存数据
                [self getCacheData:subscriber];
            
            }
            
//
            
            [self.appConnectClient skPostWithMethodName:self.path param:self.vmPara constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nullable formData) {
                @strongify(self);
                
                if (self.formDataInputBlock) {
                    self.formDataInputBlock(formData);
                }
                
            } progress:nil checkNullData:NO    successBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
                
                
                      @strongify(self);

                      [self didGetData:json subscriber:subscriber isCache:NO];
                      if(self.page == 1){
//                          只缓存第一页数据
                          [self saveJson:json];
                      }
                                                          
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json, SKErrorMsgType errorType, NSError * _Nullable error) {
                self.output = json;

                [subscriber sendError:error];
//                [subscriber sendCompleted];
                
                
                
            }];
            
            return [RACDisposable disposableWithBlock:^{
                
            }];
            
        }]setNameWithFormat:@"vm_list_skPostWithMethodName-%@",self.path];
        
        
        return signal;
        
        
        
    }];
    
  
    
    
}






@end
