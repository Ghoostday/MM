//
//  IMMTableViewMock.h
//  Moonmasons
//
//  Created by Johan Wiig on 13/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMTableViewMock : UITableView

@property NSMutableArray * insertRows;
@property NSMutableArray * deleteRows;

+ (NSUInteger) getLastIndex:(long)pos fromArray:(NSMutableArray*)array;

@end
