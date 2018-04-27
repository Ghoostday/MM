//
//  IMMInstagramEngine.m
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMInstagramEngine.h"

@implementation IMMInstagramEngine

NSString * clientId = @"ad30a9029b9740e7b4942f81fa2bcf41";
NSString * clientSecret = @"889b9aee3221442d8f8c9b6f594b794c";
NSString * redirectUri = @"http://www.moonmasons.fr/auth";
NSString * redirectUriPath = @"/auth";

+ (id)sharedInstance
{
    static IMMInstagramEngine * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init
{
    if (self = [super initWithPrefix:@"instagram"])
    {
        self.baseSearchUrl = @"https://api.instagram.com/v1/media/search";
    }
    return self;
}

- (NSMutableArray*) getResults:(IMMSearch*)search
{
    if (self.credentials == nil || self.credentials[@"access_token"] == nil)
    {
        return nil;
    }
    
    NSString * url = self.baseSearchUrl;
    
    url = [url stringByAppendingString:@"?lat="];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%f", search.position.latitude]];

    url = [url stringByAppendingString:@"&lng="];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%f", search.position.longitude]];

    url = [url stringByAppendingString:@"&distance="];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%f", search.radius]];

    url = [url stringByAppendingString:@"&access_token="];
    url = [url stringByAppendingString:self.credentials[@"access_token"]];
    
    url = [url stringByAppendingString:@"&client_id="];
    url = [url stringByAppendingString:@"0c51fc91770e47bba7df5456d6c874ba"];

    
    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSHTTPURLResponse *response = [NSHTTPURLResponse alloc];
    NSError *connectionError = [NSError alloc];
    NSData *rawData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError.code != 0)
    {
        return [[NSMutableArray alloc] init];
    }
    
    if (response.statusCode != 200)
    {
        return nil;
    }
    
    // DELETE SECTION
//    NSString * resultStr = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
//    NSLog(@"result: %@", resultStr);

    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:NULL];
    NSDictionary * data = [result objectForKey:@"data"];

    NSMutableArray * photoList = [[NSMutableArray alloc] init];
    for (NSDictionary * element in data)
    {
        IMMPhoto * photo = [[IMMPhoto alloc] init];
        NSDictionary * location = element[@"location"];
        NSDictionary * images = element[@"images"];
        NSDictionary * standard = images[@"standard_resolution"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [location[@"latitude"] floatValue];
        coordinate.longitude = [location[@"longitude"] floatValue];
        photo.coordinate = coordinate;
        photo.url = [NSURL URLWithString:standard[@"url"]];
        photo.date = [NSDate dateWithTimeIntervalSince1970:[element[@"created_time"] integerValue]];
        photo.username = [NSString stringWithFormat:@"http://www.instagram.com/%@", element[@"user"][@"username"]];
        photo.userId = element[@"user"][@"id"];
        photo.label = [NSString stringWithFormat:@"LIKES: %ld", (long)[element[@"likes"][@"count"] integerValue]];
        photo.likes = (int) [element[@"likes"][@"count"] integerValue];
        
        NSRange underscore = [element[@"id"] rangeOfString:@"_"];
        underscore.length = underscore.location;
        underscore.location = 0;
        photo.identifier = [[element[@"id"] substringWithRange:underscore] longLongValue];
        photo.provider = [self providerIdentifier];
        
        [photoList addObject:photo];
    }
    
    return photoList;
}

- (BOOL)checkUrl:(NSURL *)url
{
    if ([url.path isEqualToString:redirectUriPath]) {
        
        NSString *code = [url.query substringFromIndex:5];
        NSLog(@"Ok, close navigator code=%@", code);
        
        
        NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];
        
        NSString *postString = @"grant_type=authorization_code&client_id=";
        postString = [postString stringByAppendingString:clientId];
        postString = [postString stringByAppendingString:@"&client_secret="];
        postString = [postString stringByAppendingString:clientSecret];
        postString = [postString stringByAppendingString:@"&redirect_uri="];
        postString = [postString stringByAppendingString:redirectUri];
        postString = [postString stringByAppendingString:@"&code="];
        postString = [postString stringByAppendingString:code];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse *response = [NSURLResponse alloc];
        NSError *connectionError = [NSError alloc];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        self.credentials = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog(@"user = %@", self.credentials[@"user"]);
        
        return true;
    }
    return false;
}

- (NSString*)authUrl;
{
    NSString * authorizeUrl = @"https://api.instagram.com/oauth/authorize/?response_type=code";
    authorizeUrl =[authorizeUrl stringByAppendingString:@"&client_id="];
    authorizeUrl =[authorizeUrl stringByAppendingString:clientId];
    authorizeUrl =[authorizeUrl stringByAppendingString:@"&redirect_uri="];
    authorizeUrl =[authorizeUrl stringByAppendingString:redirectUri];
    
    return authorizeUrl;
}

- (NSString*)description
{
    return @"instagram";
}

- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request;
{
    [request setValue:@"com.innology.moonmasons.security.authentication.InstagramAuthentication" forHTTPHeaderField:@"AuthProvider"];
    [request setValue:self.credentials[@"user"][@"id"] forHTTPHeaderField:@"user_id"];
    [request setValue:self.credentials[@"access_token"] forHTTPHeaderField:@"access_token"];
    return request;
}

- (int) providerIdentifier
{
    return IMMSearchProviderIdentifierInstagram;
}

- (NSString*) userId
{
    return self.credentials[@"user"][@"id"];
}


@end
