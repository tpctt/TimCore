//
//  ViewController.m
//  TimBaseListViewModel
//
//  Created by tim on 16/11/17.
//  Copyright © 2016年 timRabbit. All rights reserved.
//

#import "ViewController.h"
#import "TQBCheckViewModel.h"
#import "AgentTypeViewModel.h"
#import "MBProgressHUD.h"


@interface ViewController ()
@property( nonatomic,strong) TQBCheckViewModel *checkViewModel;
@property( nonatomic,strong) AgentTypeViewModel *agentTypeViewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    [self checkUpdate];

    self.view.backgroundColor = [UIColor grayColor];
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkData];
    
}
-(void)checkData
{
    
    self.agentTypeViewModel = [[AgentTypeViewModel alloc] init];
    
    [self.agentTypeViewModel.command.executing subscribeNext:^(id x) {
        if ([x boolValue]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:1];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:1 ];
            
        }
    }];
    
    [ self.agentTypeViewModel.command.executionSignals.switchToLatest subscribeNext:^(id x) {

        NSLog(@"%@",x);
    
        
    }error:^(NSError *error) {
        
    }];
    
    [ self.agentTypeViewModel.command execute:nil];
    
}

-(void)checkUpdate
{
    
    self.checkViewModel = [[TQBCheckViewModel alloc] init];
    
    [ self.checkViewModel.command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);

    }error:^(NSError *error) {
        ///收不到
        
    }];
    [self.checkViewModel.command.errors subscribeNext:^(id x) {
        ///能收到
        
    }];
    //
    [[ self.checkViewModel.command execute:nil]subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        ///能收到
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
