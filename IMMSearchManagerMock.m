//
//  IMMSearchManagerMock.m
//  Moonmasons
//
//  Created by Johan Wiig on 12/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchManagerMock.h"

@implementation IMMSearchManagerMock


- (NSMutableArray*) promotedSearches
{
    return _promotedSearchesMock;
}

- (NSMutableArray*) allSearches
{
    return _allSearchesMock;
}

@end
