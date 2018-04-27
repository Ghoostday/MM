//
//  IMMTableViewMock.m
//  Moonmasons
//
//  Created by Johan Wiig on 13/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMTableViewMock.h"

@implementation IMMTableViewMock

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!_insertRows)
    {
        _insertRows = [[NSMutableArray alloc] init];
    }
    _insertRows = [[_insertRows arrayByAddingObjectsFromArray:indexPaths] mutableCopy];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!_deleteRows)
    {
        _deleteRows = [[NSMutableArray alloc] init];
    }
    _deleteRows = [[_deleteRows arrayByAddingObjectsFromArray:indexPaths] mutableCopy];
}

+ (NSUInteger) getLastIndex:(long)pos fromArray:(NSMutableArray*)array
{
    NSIndexPath * insert = (NSIndexPath*) array[pos];
    NSUInteger i[[insert length]];
    [insert getIndexes: i];
    return i[[insert length] - 1];
}

@end
