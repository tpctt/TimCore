//
//  BaseViewModel.h
//  taoqianbao
//
//  Created by tim on 16/9/6.
//  Copyright © 2016年 tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import <TMCache.h>
#import <TimAFAppConnectClient.h>
#import <CoreSpotlight/CoreSpotlight.h>



typedef NSArray* _Nullable(^RACCommandChanged)( NSDictionary * _Nullable dict);
typedef _Nullable id(^RACCommandOutput)(NSDictionary * _Nullable output);
typedef NSDictionary* _Nullable(^RACCommandInput)(NSMutableDictionary *_Nullable input);
typedef void(^RACCommandFormDdataInput)(id <AFMultipartFormData>  _Nullable formData);



@protocol TimSearchItemForObjectProtocol <NSObject>
///获取用于转换为搜索的数据
-(CSSearchableItem *)searchableItem;
///用于处理Appledelegate 传来的搜索选择动作的数据
-(void)continueUserActivityWith:(NSDictionary *)mj_keyValues;


@end

@interface TimBaseViewModel : NSObject
{
    TimAFAppConnectClient *_Nullable _appConnectClient;
}
@property (nonatomic, strong) RACCommand * _Nullable command;
@property (nonatomic, strong) NSString * _Nonnull path;
@property (nonatomic, strong) NSDictionary * _Nonnull vmPara;

@property (nonatomic, strong) id _Nullable output;///收到的
@property (nonatomic, strong) NSString *_Nullable msg;
@property (nonatomic, copy) RACCommandOutput _Nullable outputBlock;
@property (nonatomic, copy) RACCommandInput _Nullable inputBlock;
@property (nonatomic, copy) RACCommandFormDdataInput _Nullable formDataInputBlock;

@property (nonatomic, assign ) BOOL allowCacheData;
@property (nonatomic, strong,readonly ) TimAFAppConnectClient *_Nullable appConnectClient;


- (void)initialize ;
+(NSMutableDictionary* _Nonnull)addBaseInfo:(NSDictionary* _Nullable)info forWeb:(BOOL)forWeb;

///cache
-(void)didGetData:(id  _Nullable )json subscriber:(id<RACSubscriber>_Nullable) subscriber isCache:(BOOL)isCache;
-(NSString *_Nullable)getCacheKey;

///spot
-(NSArray *)getSearchArray;
-(void)dealArrayToSearch:(NSArray *)array;

@end




////list 的 VM
@interface TimBaseListViewModel : TimBaseViewModel

@property (nonatomic, strong) NSArray * _Nullable dataArray;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger totalPage;

@property (nonatomic, copy) RACCommandChanged _Nullable block;///转 array 的 block

@property (nonatomic, strong) Class _Nullable listObjClass;


-(RACSignal* _Nullable )loadFirstPage;
-(RACSignal* _Nullable)loadNextPage;



@end
