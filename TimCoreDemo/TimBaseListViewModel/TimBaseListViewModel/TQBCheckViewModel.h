//
//  TQBCheckViewModel.h
//  taoqianbao
//
//  Created by tim on 16/9/27.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "BaseListViewModel.h"

@class TQBCheckModel;

@interface TQBCheckViewModel : BaseViewModel
//out
@property (strong,nonatomic) TQBCheckModel *versionObj;

@end

@interface TQBCheckModel : NSObject

@property (strong,nonatomic) NSString *id;
@property (strong,nonatomic) NSString *version;
@property (assign,nonatomic) BOOL force;
@property (strong,nonatomic) NSString *remark;
@property (strong,nonatomic) NSString *download_url;
@property (strong,nonatomic) NSString *created_at;


@end
