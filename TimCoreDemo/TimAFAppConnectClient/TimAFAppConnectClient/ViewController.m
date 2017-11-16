//
//  ViewController.m
//  TimAFAppConnectClient
//
//  Created by tim on 16/11/17.
//  Copyright © 2016年 timRabbit. All rights reserved.
//

#import "ViewController.h"
#import "TimAFAppConnectClient.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [TimAFAppConnectClient setBaseUrl:@"http://api.taoqian123.com/v1/"];
    TimAFAppConnectClient *share = [TimAFAppConnectClient sharedClientFor:@"https://api.taoqian123.com/v1/"];
    TimAFAppConnectClient *share2 = [TimAFAppConnectClient sharedClientFor:@"https://api.kehufox.com/v2/"];
    TimAFAppConnectClient *share3 = [TimAFAppConnectClient sharedClientFor:@"https://api.taoqian123.com/v1/"];

    {
        [share setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];
        
        share.dnsTable = @{@"api.taoqian123.com":@"120.27.142.86"};
        
        [share skPostWithMethodName:@"public/version" param:@{@"version":@"1.0.0",@"front":@"2"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nullable formData) {
            
        } progress:nil checkNullData:YES
                       successBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
                           NSLog(@"%@",json);
                           
                       } failedBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json, SKErrorMsgType errorType, NSError * _Nullable error) {
                           NSLog(@"%@",error);
                           
                       }];
    }
    
    {
        [share2 setSucessCode:1 statusCodeKey:@"status" msgKey:@"info" responseDataKey:@"data"];
        
//        share2.dnsTable = @{@"api.taoqian123.com":@"120.27.142.86"};
        
        [share2 skPostWithMethodName:@"public/version" param:@{@"version":@"1.0.0",@"front":@"2"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nullable formData) {
            
        } progress:nil checkNullData:YES
                       successBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
                           NSLog(@"%@",json);
                           
                       } failedBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json, SKErrorMsgType errorType, NSError * _Nullable error) {
                           NSLog(@"%@",error);
                           
                       }];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
