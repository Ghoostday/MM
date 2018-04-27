//
//  IMMSearchManager.h
//  Moonmasons
//
//  Created by Johan Wiig on 09/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMSearch.h"
#import "IMMCurrentLocationSearch.h"
#import "IMMProviderEngine.h"
#import "IMMSearchProvider.h"

enum IMMCanBoostZoneResult
{
    IMMCanBoostZoneResultYes = 0,
    IMMCanBoostZoneResultPhotoLimit,
    IMMCanBoostZoneResultZoneLimit,
    IMMCanBoostZoneResultLength
};

@interface IMMSearchManager : NSObject <IMMSearchProvider>

@property IMMProviderEngine * authRequested;
@property (readonly) NSMutableArray * searches;
@property (readonly) NSMutableArray * engines;
@property (readonly, nonatomic) IMMCurrentLocationSearch * currentLocationSearch;
@property NSString * appBase;
@property int timeout;
@property int photosNeededToBoost;
@property int maxBoostZones;

+ (id) sharedInstance;
- (long) searchEnginesEnabled;

- (void) request:(NSMutableDictionary*)object
             url:(NSString*)url
          method:(NSString*)method
         handler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler;
- (NSMutableDictionary*) dictionary:(IMMSearch*)search;
- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request;

- (void) add:(IMMSearch*)search;
- (void) update:(IMMSearch*)search;
- (void) remove:(IMMSearch*)search;
- (void) isBoosted:(IMMSearch*)search callback:(void(^)(BOOL))callback;
- (int) canBoost:(IMMSearch*)search;

- (NSMutableArray*) promotedSearches;
- (void) clearCache;

@end
