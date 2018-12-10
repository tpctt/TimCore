//
//  TimSearchItemForObjectProtocol.h
//  TimCoreDemo
//
//  Created by tim on 17/2/4.
//  Copyright © 2017年 tim. All rights reserved.
//

#ifndef TimSearchItemForObjectProtocol_h
#define TimSearchItemForObjectProtocol_h

@protocol TimSearchItemForObjectProtocol <NSObject>
///获取用于转换为搜索的数据
-(CSSearchableItem *)searchableItem;
///用于处理Appledelegate 传来的搜索选择动作的数据
-(void)continueUserActivityWith:(NSDictionary *)mj_keyValues;


@end


#endif /* TimSearchItemForObjectProtocol_h */
