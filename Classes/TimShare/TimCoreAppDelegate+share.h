//
//  3rd.h
//  taoqianbao
//
//  Created by tim on 16/11/1.
//  Copyright © 2016年 tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "TimCoreAppDelegate.h"



typedef void(^ShareResult)(BOOL sucess,NSString *msg);

@interface   TimCoreAppDelegate(share)

-(void)initSharedSDK;

-(void)shareInfo:(NSString *)title content:(NSString *)content image:(id)image  url:(NSString *)url actionSheet:(UIView *)actionSheet onShareStateChanged:(ShareResult)shareStateChangedHandler;

    
@end
