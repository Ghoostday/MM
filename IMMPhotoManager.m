//
//  IMMPhotoManager.m
//  Moonmasons
//
//  Created by Johan Wiig on 02/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMPhotoManager.h"

@implementation IMMPhotoManager

+ (id) sharedInstance
{
    static IMMPhotoManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[self alloc] init];
                  });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        _timeout = 5;
        _searchManager = [IMMSearchManager sharedInstance];
        return self;
    }
    return nil;
}

- (void)setBoost:(IMMPhoto*)photo boost:(BOOL)boost
{
    @try
    {
        NSString * url = boost ?  [_appBase stringByAppendingString:@"/boostPhoto"] : [_appBase stringByAppendingString:@"/unBoostPhoto"];
        [_searchManager request:[self dictionary:photo]
                            url:url
                         method:@"POST"
                        handler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error.code != 0 || ((NSHTTPURLResponse *) response).statusCode > 299)
             {
                 NSLog(@"Photo boost error: %@ http status: %ld", error, (long)((NSHTTPURLResponse *) response).statusCode);
                 return;
             }
         }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"error: %@", exception);
    }
}

- (void)isBoosted:(IMMPhoto*)photo callback:(void(^)(BOOL))callback
{
    @try
    {
        [_searchManager request:[self dictionary:photo]
                            url:[_appBase stringByAppendingString:@"/isPhotoBoosted"]
                         method:@"POST"
                        handler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error.code != 0 || ((NSHTTPURLResponse *) response).statusCode > 299)
             {
                 NSLog(@"isBoosted error: %@ http status: %ld", error, (long)((NSHTTPURLResponse *) response).statusCode);
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

- (NSMutableDictionary*) dictionary:(IMMPhoto*)photo
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:photo.coordinate.latitude], @"latitude",
            [NSNumber numberWithDouble:photo.coordinate.longitude], @"longitude",
            [photo.url absoluteString], @"url",
            [NSNumber numberWithLongLong:((long long)[photo.date timeIntervalSince1970] * 1000)], @"date",
            photo.username, @"username",
            [NSNumber numberWithInt:photo.provider], @"provider",
            [NSNumber numberWithLongLong:photo.identifier], @"identifier",
            nil];
}

NSDate * promotedPhotosExpiration;

- (NSMutableArray*) boostedPhotos
{
    if (promotedPhotosExpiration)
    {
        NSDate * now = [[NSDate alloc] init];
        if ([now compare:promotedPhotosExpiration] == NSOrderedAscending)
        {
            NSLog(@"Boosted photos cache is valid, returning");
            return _boostedPhotos;
        }
    }
    NSLog(@"Boosted photos cache is invalid, fetching");
    
    _boostedPhotos = [[NSMutableArray alloc] init];
    
    @try
    {
        NSMutableArray * jsonArray = [[NSMutableArray alloc] init];
        for (IMMSearch * search in [_searchManager allSearches])
        {
            if (search.active && !search.negative)
            {
                [jsonArray addObject:[_searchManager dictionary:search]];
            }
        }
        
        NSError *error = [[NSError alloc] init];
        NSData * reqData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_appBase stringByAppendingString:@"/promotedPhotos"]]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:reqData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:_timeout];
        request = [_searchManager addAuthHeaders:request];
        
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
                promotedPhotosExpiration = [dateFormatter dateFromString:headers[@"Expires"]];
                
                for (NSDictionary * element in result)
                {
                    if (element)
                    {
                        IMMPhoto * photo = [[IMMPhoto alloc] init];
                        CLLocationCoordinate2D coordinate;
                        coordinate.latitude = [element[@"latitude"] floatValue];
                        coordinate.longitude = [element[@"longitude"] floatValue];
                        photo.coordinate = coordinate;
                        photo.url = [NSURL URLWithString:element[@"url"]];
                        photo.date = [NSDate dateWithTimeIntervalSince1970:([element[@"date"] longLongValue] / 1000)];
                        photo.username = element[@"username"];
                        photo.rank = [element[@"rank"] floatValue];
                        photo.boost = [element[@"numberOfBoosts"] intValue];
                        photo.label = @"";
                        photo.identifier = [element[@"identifier"] longLongValue];
                        photo.provider = [element[@"provider"] intValue];
                        
                        [_boostedPhotos addObject:photo];
                    }
                }
            }
            else
            {
                NSLog(@"get boosted error: %ld", (long)error.code);
                NSLog(@"get boosted error: %@", error);
            }
        }
        else
        {
            NSLog(@"get boosted error: %ld, response.statusCode: %ld", (long)error.code, (long)response.statusCode);
            NSLog(@"get boosted error: %@", error);
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"get boosted error: %@", exception);
    }
    
    return _boostedPhotos;
}

- (void) clearCache
{
    promotedPhotosExpiration = nil;
}


@end
