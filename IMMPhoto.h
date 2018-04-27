//
//  IMMPhoto.h
//  Moonmasons
//
//  Created by Johan Wiig on 07/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface IMMPhoto : NSObject

@property NSURL * url;
@property UIImage * image;
@property CLLocationCoordinate2D coordinate;
@property NSDate * date;
@property NSString * label;
@property NSString * username;
@property NSString * userId;
@property float rank;
@property int boost;
@property int likes;
@property unsigned long long identifier;
@property int provider;

- (NSComparisonResult)compare:(IMMPhoto *)otherObject;

@end
