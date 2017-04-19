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
        
        [self initNetClient];
        
        [self initialize];
        [self initNetError];
        
        
    }
    return self;
}
-(void)initNetClient
{
    _appConnectClient =   [TimAFAppConnectClient sharedClientFor:self.baseUrl];
    
}
-(void)setSucessCode:(NSInteger)sucessCode statusCodeKey:(NSString *_Nonnull)statusCodeKey msgKey:(NSString *_Nonnull)msgKey responseDataKey:(NSString * _Nonnull)responseDataKey
{
    [_appConnectClient setSucessCode:sucessCode statusCodeKey:statusCodeKey msgKey:msgKey responseDataKey:responseDataKey];
}


-(void)setBaseUrl:(NSString *)baseUrl
{
    
    NSAssert(baseUrl, @"baseurl 不得为空");
    
    if (_baseUrl == nil) {
        _baseUrl = baseUrl;
    }else{
        
        NSParameterAssert(@"baseurl 设置之后不得修改");
        
    }
    
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
    
    
    [self dealData:dict subscriber:subscriber];
    
    
    [self dealArrayToSearch:[self getSearchArray]];
    
    
    if(isCache == NO){
        [subscriber sendCompleted];
    }
    
    
}

-(void)dealData:(NSDictionary *)dict subscriber:(id<RACSubscriber>) subscriber
{
    if(self.outputBlock){
        
        [subscriber  sendNext:self.outputBlock(dict)];
        
        
    }else{
        
        [subscriber sendNext:dict];
        
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

///处理输入参数
-(void)dealInputPara
{
    
    self.vmPara = [[self class]addBaseInfo:self.vmPara forWeb:NO];
    if ( self.inputBlock) {
        self.vmPara = self.inputBlock([self.vmPara mutableCopy]);
    }
}

#pragma mark 实现过程
- (void)initialize
{
    @weakify(self);
    
    
    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        RACSignal *signal =   [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            
            ///检测 path 有效性
            NSAssert(self.path.length  , ([NSString stringWithFormat:@"%@ %@ path 为空",self ,self.path ]));
            if ( ! self.path.length) {
                
                return [RACDisposable disposableWithBlock:^{}];
                
            }
            
            
            [self dealInputPara];
            [self getCacheData:subscriber];
            
            ///网络请求
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
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString*  appVersion =[NSString stringWithFormat:@"%@",  [infoDict objectForKey:@"CFBundleShortVersionString"]  ];
        ///现在的app的版本
        [mParam setObject:appVersion forKey:@"version"];
        
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
    
    
}


@end



////
@implementation TimBaseListViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = 1;
        self.dataArray = [NSMutableArray array];
        
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
    return  [self.command execute:nil];
}
-(void)dealData:(NSDictionary *)dict subscriber:(id<RACSubscriber>) subscriber
{
    NSArray *array = nil;
    if(self.block){
        array = self.block( dict );
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
    
    
    [self dealArrayToSearch:array];
    
    
}


-(void)dealInputPara
{
    [super dealInputPara];
    NSMutableDictionary *para = [self.vmPara mutableCopy];
    [ para setObject:@(self.page) forKey:@"page"];
    self.vmPara = para;
    
}
-(void)getCacheData:(id<RACSubscriber>)subscriber
{
    if(self.page == 1){
        ///只使用第一页缓存数据
        [super getCacheData:subscriber];
        
    }
}
-(void)saveJson:(id)json
{
    if(self.page == 1){
        //     只缓存第一页数据
        [super saveJson:json];
    }
}





@end
