//
//  IMMSearchManager.m
//  Moonmasons
//
//  Created by Johan Wiig on 09/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchManager.h"
#import "IMMSearch.h"
#import "IMMTwitterEngine.h"
#import "IMMInstagramEngine.h"

@implementation IMMSearchManager

@synthesize searches;
@synthesize engines;
@synthesize authRequested;
@synthesize currentLocationSearch = _currentLocationSearch;

NSDate * promotedSearchesExpiration;
NSMutableArray * promotedSearches;

+ (id) sharedInstance
{
    static IMMSearchManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[self alloc] init];
    });
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        _timeout = 5;
        _photosNeededToBoost = 0;
        searches = [[NSMutableArray alloc] init];
        engines = [[NSMutableArray alloc] init];
        [engines addObject:[IMMInstagramEngine sharedInstance]];
        [engines addObject:[IMMTwitterEngine sharedInstance]];
        [self load];
    }
    return self;
}

- (IMMCurrentLocationSearch*) currentLocationSearch
{
    if (!_currentLocationSearch)
    {
        _currentLocationSearch = [[IMMCurrentLocationSearch alloc] init];
    }
    return _currentLocationSearch;
}

- (long) searchEnginesEnabled
{
    long count = 0;
    for (IMMProviderEngine * engine in engines)
    {
        if (engine.enabled)
        {
            count++;
        }
    }
    return count;
}

- (NSMutableArray *) allSearches
{
    return [[searches arrayByAddingObject:_currentLocationSearch] mutableCopy];
}


//  PERISTANCE
- (void) load
{
    NSMutableArray * archiveArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"searches"];
    if (archiveArray != nil)
    {
        for (int i = 0 ; i < archiveArray.count ; i++)
        {
            IMMSearch * search = [NSKeyedUnarchiver unarchiveObjectWithData:archiveArray[i]];
            [searches addObject:search];
        }
    }

}

- (void)save
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:searches.count];
    for (IMMSearch *search in searches)
    {
        NSData *searchEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:search];
        [archiveArray addObject:searchEncodedObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:archiveArray forKey:@"searches"];
}

- (void) add:(IMMSearch*)search
{
    [searches addObject:search];
    [self save];
}

- (void) update:(IMMSearch*)search
{
    [self save];
    NSString * url = search.boost ? [_appBase stringByAppendingString:@"/boostSearch"] : [_appBase stringByAppendingString:@"/unBoostSearch"];
    search.boost ? [self updateServer:search url:url] : [self updateServer:search url:url];
}

- (void) remove:(IMMSearch*)search
{
    [searches removeObject:search];
    [self save];
    [self updateServer:search url:[_appBase stringByAppendingString:@"/unBoostSearch"]];

}

- (void) updateServer:(IMMSearch*)search url:(NSString*)url
{
    @try
    {
        NSMutableDictionary * obj = [self dictionary:search];
        [self request:obj
                  url:url
               method:@"POST"
              handler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error.code != 0 || ((NSHTTPURLResponse *) response).statusCode > 299)
             {
                 NSLog(@"Search save error: %@ http status: %ld", error, (long)((NSHTTPURLResponse *) response).statusCode);
                 return;
             }
         }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"error: %@", exception);
    }
}

- (void)isBoosted:(IMMSearch*)search callback:(void(^)(BOOL))callback
{
    @try
    {
        [self request:[self dictionary:search]
                  url:[_appBase stringByAppendingString:@"/isSearchBoosted"]
               method:@"POST"
              handler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error.code != 0 || ((NSHTTPURLResponse *) response).statusCode > 299)
             {
                 NSLog(@"Search pull error: %@ http status: %ld", error, (long)((NSHTTPURLResponse *) response).statusCode);
                 callback(false);
                 return;
             }
             NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"result = %@", result);
             callback([result boolValue]);
         }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"error: %@", exception);
        callback(false);
    }
}

- (int) canBoost:(IMMSearch*)search
{
    int result = IMMCanBoostZoneResultYes;
    
    int photoCount = 0;
    for (IMMPhoto * photo in search.result)
    {
        for (IMMProviderEngine * engine in engines)
        {
            if ([engine.userId isEqualToString:photo.userId])
            {
                photoCount++;
            }
        }
    }
    if (photoCount < _photosNeededToBoost)
    {
        result = IMMCanBoostZoneResultPhotoLimit;
    }
    
    int boostZoneCount = 0;
    for (IMMSearch * item in searches)
    {
        if (item.boost)
        {
            boostZoneCount++;
        }
    }
    if (boostZoneCount > (_maxBoostZones - 1))
    {
        result = IMMCanBoostZoneResultZoneLimit;
    }

    return result;
}


- (NSMutableArray*) promotedSearches
{
    
    if (promotedSearchesExpiration)
    {
        NSDate * now = [[NSDate alloc] init];
        if ([now compare:promotedSearchesExpiration] == NSOrderedAscending)
        {
            NSLog(@"Promoted searches cache is valid, returning");
            return promotedSearches;
        }
    }
    NSLog(@"Promoted searches cache is invalid, fetching");

    promotedSearches = [[NSMutableArray alloc] init];
    
    @try
    {
        NSMutableArray * jsonArray = [[NSMutableArray alloc] init];
        for (IMMSearch * search in [self allSearches])
        {
            if (search.active && !search.negative)
            {
                [jsonArray addObject:[self dictionary:search]];
            }
        }
        
        NSError *error = [[NSError alloc] init];
        NSData * reqData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_appBase stringByAppendingString:@"/promotedSearches"]]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:reqData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:_timeout];
        request = [self addAuthHeaders:request];
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error.code == 0 && response.statusCode < 299)
        {
            NSArray * result = [NSJSONSerialization JSONObjectWithData:resData options:0 error:&error];
            if (error.code == 0)
            {
                NSDictionary * headers = [response allHeaderFields];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormatter setLocale:usLocale];
                promotedSearchesExpiration = [dateFormatter dateFromString:headers[@"Expires"]];

                for (NSDictionary * element in result)
                {
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [element[@"latitude"] floatValue];
                    coordinate.longitude = [element[@"longitude"] floatValue];
                    
                    IMMSearch * search = [[IMMSearch alloc] initWithCoordinates:coordinate];
                    search.radius = [element[@"radius"] floatValue];
                    search.rank = [element[@"rank"] floatValue];
                    [promotedSearches addObject:search];
                }
            }
            else
            {
                NSLog(@"error: %ld", (long)error.code);
            }
        }
        else
        {
            NSLog(@"error: %ld, response.statusCode: %ld", (long)error.code, (long)response.statusCode);
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"error: %@", exception);
    }
    
    return promotedSearches;
}

//  AUTHENTICATION AND COM
- (void) request:(NSMutableDictionary*)object
             url:(NSString*)url
          method:(NSString*)method
         handler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSError * error = [[NSError alloc] init];
    if (object != nil)
    {
        NSData * json = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (error.code != 0)
        {
            NSLog(@"JSON encoding error: %@", error);
        }
        [request setHTTPMethod:method];
        [request setHTTPBody:json];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request = [self addAuthHeaders:request];
    if (request == nil)
    {
        return;
    }
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:handler];
}

- (NSMutableDictionary*) dictionary:(IMMSearch*)search
{
   return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithDouble:search.position.latitude], @"latitude",
        [NSNumber numberWithDouble:search.position.longitude], @"longitude",
        [NSNumber numberWithFloat:search.radius], @"radius",
        [NSNumber numberWithBool:search.boost], @"boosted",
        [NSNumber numberWithBool:search.active], @"active",
        [NSNumber numberWithBool:search.negative], @"negative",
        [NSNumber numberWithBool:search.alert], @"alert",
        nil];
}

- (long) identifierFromPath:(NSString*)path
{
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    return [[path substringFromIndex:range.location + 1] integerValue];
}

- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request
{
    IMMProviderEngine * provider = [self authProvider];
    if (provider != nil)
    {
        return [provider addAuthHeaders:request];
    }
    return nil;
}

- (IMMProviderEngine*) authProvider
{
    for (IMMProviderEngine * provider in engines)
    {
        if (provider.enabled)
        {
            return provider;
        }
    }    
    return nil;
}

- (void) clearCache
{
    promotedSearchesExpiration = nil;
}


@end

