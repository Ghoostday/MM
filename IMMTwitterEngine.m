//
//  IMMTwitterEngine.m
//  Moonmasons
//
//  Created by Johan Wiig on 09/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMTwitterEngine.h"
#import "IMMoAuth.h"

@implementation IMMTwitterEngine



NSString * key = @"b4Fy1t8YxqTxXe80nWXnG1xNr";
NSString * secret = @"wQs5Ib6yMKo640LoQYcSY79BisHUIL9CGZzYD5ELYP8SEtFO5c";

NSString * callbackUrl = @"http://www.moonmasons.fr/auth";
NSString * callbackUrlPath = @"/auth";

NSString * requestUrl = @"https://api.twitter.com/oauth/request_token";
NSString * authenticateUrl = @"https://api.twitter.com/oauth/authorize";
NSString * accessUrl = @"https://api.twitter.com/oauth/access_token";


+ (id)sharedInstance
{
    static IMMTwitterEngine * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init
{
    if (self = [super initWithPrefix:@"twitter"])
    {
        self.baseSearchUrl = @"https://api.twitter.com/1.1/search/tweets.json";
    }
    return self;
}

- (NSMutableArray*) getResults:(IMMSearch*)search
{
    if (self.credentials == nil || self.credentials[@"oauth_token"] == nil  || self.credentials[@"oauth_token_secret"] == nil )
    {
        return nil;
    }


    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.baseSearchUrl]];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[@"count"] = @"100";
    params[@"geocode"] =  [NSString stringWithFormat:@"%f,%f,%lukm", search.position.latitude, search.position.longitude, (unsigned long) search.radius / 1000];
    
    NSString * authHeader = [IMMoAuth OAuthHeader:request
                                       parameters:params
                               oauth_consumer_key:key
                            oauth_consumer_secret:secret
                                      oauth_token:self.credentials[@"oauth_token"]
                               oauth_token_secret:self.credentials[@"oauth_token_secret"]];
    
    NSString * url = [NSString stringWithFormat:@"%@?count=100&geocode=%f", self.baseSearchUrl, search.position.latitude];
    url = [url stringByAppendingString:@"%2C"];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%f", search.position.longitude]];
    url = [url stringByAppendingString:@"%2C"];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%lukm", (unsigned long) search.radius / 1000]];

    request.URL = [NSURL URLWithString:url];
    
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    
    NSHTTPURLResponse *response = [NSHTTPURLResponse alloc];
    NSError *connectionError = [NSError alloc];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];

// DELETE SECTION
//    NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"result: %@", resultStr);

    if (connectionError.code != 0)
    {
        return [[NSMutableArray alloc] init];
    }
    
    if (response.statusCode != 200)
    {
        return nil;
    }
    
    
    NSMutableArray * photoList = [[NSMutableArray alloc] init];
    
    NSDictionary * json = [NSJSONSerialization
                           JSONObjectWithData:data
                           options:0
                           error:&connectionError];
    
    NSMutableDictionary * tweets = json[@"statuses"];
    
    for (NSDictionary * tweet in tweets)
    {
        
        NSDate * date;
        NSString * url;
        CLLocationCoordinate2D coordinate;
        NSString * username;
        NSString * userId;
        long likes = 0;
        unsigned long long identifier;
        
        
        if (tweet[@"entities"] && tweet[@"entities"][@"media"] && [tweet[@"entities"][@"media"] isKindOfClass:[NSArray class]])
        {
            NSArray * media = tweet[@"entities"][@"media"];
            if (media.count != 0)
            {
                NSString * strMedia = ((NSObject*)media[0]).description;
                
                NSRange keyPosition = [strMedia rangeOfString:@"\"media_url\""];
                if (keyPosition.location == NSNotFound) break;
                
                NSRange equalSearch = NSMakeRange(keyPosition.location + keyPosition.length, strMedia.length - (keyPosition.location + keyPosition.length));
                NSRange equalPosition = [strMedia rangeOfString:@"=" options:0 range:equalSearch];
                if (equalPosition.location == NSNotFound) break;
                
                NSRange urlStartSearch = NSMakeRange(equalPosition.location + equalPosition.length, strMedia.length - (equalPosition.location + equalPosition.length));
                NSRange urlStartPosition = [strMedia rangeOfString:@"\"" options:0 range:urlStartSearch];
                if (urlStartPosition.location == NSNotFound) break;
                
                NSRange urlEndSearch = NSMakeRange(urlStartPosition.location + urlStartPosition.length, strMedia.length - (urlStartPosition.location + urlStartPosition.length));
                NSRange urlEndPosition = [strMedia rangeOfString:@"\"" options:0 range:urlEndSearch];
                if (urlEndPosition.location == NSNotFound) break;
                
                NSRange urlPosition;
                urlPosition.location = urlStartPosition.location + 1;
                urlPosition.length = urlEndPosition.location - urlStartPosition.location - 1;
                
                url = [strMedia substringWithRange:urlPosition];
            }
            
        }
        
        if (tweet[@"coordinates"] && ![tweet[@"coordinates"] isKindOfClass:[NSNull class]] && tweet[@"coordinates"][@"coordinates"] && [tweet[@"coordinates"][@"coordinates"] isKindOfClass:[NSArray class]])
        {
            NSArray * coordinateArray = tweet[@"coordinates"][@"coordinates"];
            if (coordinateArray.count == 2)
            {
                coordinate.longitude = [coordinateArray[0] floatValue];
                coordinate.latitude = [coordinateArray[1] floatValue];
            }
        }
        
        if (tweet[@"created_at"] && ![tweet[@"created_at"] isKindOfClass:[NSNull class]])
        {
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
            date = [dateFormatter dateFromString:tweet[@"created_at"]];
        }
        
        if (tweet[@"user"] && ![tweet[@"user"] isKindOfClass:[NSNull class]] && tweet[@"user"][@"screen_name"] && ![tweet[@"user"][@"screen_name"] isKindOfClass:[NSNull class]])
        {
            username = [NSString stringWithFormat:@"http://twitter.com/%@", tweet[@"user"][@"screen_name"]];
        }

        if (tweet[@"user"] && ![tweet[@"user"] isKindOfClass:[NSNull class]] && tweet[@"user"][@"screen_name"] && ![tweet[@"user"][@"screen_name"] isKindOfClass:[NSNull class]])
        {
            userId = tweet[@"id"];
        }

        if (tweet[@"retweet_count"] && ![tweet[@"retweet_count"] isKindOfClass:[NSNull class]])
        {
            likes = [tweet[@"retweet_count"] integerValue];
        }
        
        if (tweet[@"id"] && ![tweet[@"id"] isKindOfClass:[NSNull class]])
        {
            identifier = [tweet[@"id"] longLongValue];
        }
        
        if (url)
        {
            IMMPhoto * photo = [[IMMPhoto alloc] init];
            photo.url = [NSURL URLWithString:url];
            photo.date = date;
            photo.coordinate = coordinate;
            photo.username = username;
            photo.userId = userId;
            photo.label = [NSString stringWithFormat:@"RE: %ld", likes];
            photo.likes = (int) likes;
            photo.identifier = identifier;
            photo.provider = [self providerIdentifier];
            [photoList addObject:photo];
        }
    }
    
    return photoList;
}

- (BOOL)checkUrl:(NSURL *)url
{
    if ([url.path isEqualToString:callbackUrlPath])
    {
        NSLog(@"Hit trigger path, %@, closing web view", url);
        
        
        NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            self.credentials[key] = value;
        }
        NSLog(@"self.credentials: %@", self.credentials);
        
        
        
        
        self.credentials = [IMMoAuth accessTokenForUrl:accessUrl
                 oauth_consumer_key:key
              oauth_consumer_secret:secret
                        oauth_token:self.credentials[@"oauth_token"]
                 oauth_token_secret:self.credentials[@"oauth_token_secret"]
                     oauth_verifier:self.credentials[@"oauth_verifier"]
                        credentials:self.credentials];
        
        NSLog(@"credentials = %@", self.credentials);
        
        [self save];

        return true;
    }
    return false;
}

- (NSString*)authUrl;
{
    
    self.credentials = [IMMoAuth requestTokenForKey:key secret:secret callbackUrl:callbackUrl requestUrl:requestUrl];
    
    authenticateUrl = [authenticateUrl stringByAppendingString:@"?oauth_token"];
    authenticateUrl = [authenticateUrl stringByAppendingString:@"="];
    authenticateUrl = [authenticateUrl stringByAppendingString:self.self.credentials[@"oauth_token"]];
    
    NSLog(@"authenticateUrl = %@, credentials = %@", authenticateUrl, self.credentials);

    return authenticateUrl;
}

- (NSString*)description
{
    return @"twitter";
}

- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request;
{
    NSString * url = @"https://api.twitter.com/1.1/account/settings.json";
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    NSString * authHeader = [IMMoAuth OAuthHeader:req
                                       parameters:params
                               oauth_consumer_key:key
                            oauth_consumer_secret:secret
                                      oauth_token:self.credentials[@"oauth_token"]
                               oauth_token_secret:self.credentials[@"oauth_token_secret"]];
    
    [request setValue:@"com.innology.moonmasons.security.authentication.TwitterAuthentication" forHTTPHeaderField:@"AuthProvider"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:url forHTTPHeaderField:@"url"];
    [request setValue:self.credentials[@"user_id"] forHTTPHeaderField:@"user_id"];
    return request;
}

- (int) providerIdentifier
{
    return IMMSearchProviderIdentifierTwitter;
}

- (NSString*) userId
{
    return self.credentials[@"user_id"];
}


@end
