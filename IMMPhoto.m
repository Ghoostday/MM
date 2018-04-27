//
//  IMMPhoto.m
//  Moonmasons
//
//  Created by Johan Wiig on 07/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMPhoto.h"

@implementation IMMPhoto

- (NSComparisonResult)compare:(IMMPhoto *)otherObject {
    return [otherObject.date compare:_date];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"[url: %@, boost: %u, rank: %f, likes: %u, date: %@, username: %@, lat: %f, lng: %f]", _url, _boost, _rank, _likes, _date, _username, _coordinate.latitude, _coordinate.longitude];
}

@end
