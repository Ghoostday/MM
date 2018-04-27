//
//  IMMSearchEngine.m
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchEngine.h"
#import "IMMSearchManager.h"

@implementation IMMSearchEngine

NSMutableArray * organicPhotos;
NSMutableArray * promotedPhotos;
IMMSearchManager * searchManager;
bool IMMSearchEngineloading = false;

- (id)initWithAuthView:(UIViewController*)authView
{
    if (self = [super init])
    {
        _authView = authView;

        organicPhotos = [[NSMutableArray alloc] init];
        searchManager = [IMMSearchManager sharedInstance];
        
        return self;
    }
    return nil;
}

- (NSMutableArray*) organicPhotos
{
    return [self organicPhotos:false];
}

- (NSMutableArray*) organicPhotos:(BOOL)alert
{
    NSLog(@"IMMSearchEngine::result");
    if (IMMSearchEngineloading)
    {
        return [[NSMutableArray alloc] init];;
    }
    IMMSearchEngineloading = true;

    NSDate * oldFirstPicture = nil;
    if(organicPhotos.count > 0)
    {
        oldFirstPicture = ((IMMPhoto*)organicPhotos[0]).date;
    }
    
    organicPhotos = [[NSMutableArray alloc] init];
    for (IMMSearch * search in [searchManager allSearches])
    {
        if (search.active && !search.negative)
        {
            if (!alert || (alert && search.alert))
            {
                search.result = [[NSMutableArray alloc] init];
                for (IMMProviderEngine * engine in searchManager.engines)
                {
                    if (searchManager.authRequested == nil) //  No pending auth requests
                    {
                        if (engine.enabled)
                        {
                            NSMutableArray * newPhotos = [engine getResults:search];
                            if (newPhotos != nil)
                            {
                                [search.result addObjectsFromArray:newPhotos];
                                [organicPhotos addObjectsFromArray:newPhotos];
                                organicPhotos = [[organicPhotos sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
                            }
                            else
                            {
                                if (_authView != nil)
                                {
                                    searchManager.authRequested = engine;
                                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                    UIViewController *topView = window.rootViewController;
                                    [topView presentViewController:_authView animated:YES completion:nil];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSMutableArray * removePhotos = [[NSMutableArray alloc] init];
    for (IMMSearch * search in [searchManager allSearches])
    {
        if (search.active && search.negative)
        {
            for (IMMPhoto * photo in organicPhotos)
            {
                if ([search isCoveringPhoto:photo])
                {
                    //NSLog(@"Exclude photo");
                    [removePhotos addObject:photo];
                }
            }
        }
    }
    for (IMMPhoto * photo in removePhotos)
    {
        [organicPhotos removeObject:photo];
    }
    
    
    removePhotos = [[NSMutableArray alloc] init];
    for (IMMPhoto * photo in organicPhotos)
    {
        bool trim = false;
        for (IMMPhoto * match in organicPhotos)
        {
            if ([[photo.url absoluteString] isEqual:[match.url absoluteString]])
            {
                if (trim)
                {
                    [removePhotos addObject:photo];
                }
                trim = true;
            }
        }
    }
    for (IMMPhoto * photo in removePhotos)
    {
        [organicPhotos removeObject:photo];
    }


    if (organicPhotos.count > 20)
    {
        organicPhotos = [[organicPhotos subarrayWithRange:NSMakeRange(0, 20)] mutableCopy];
    }
    
    _photos = organicPhotos;
    
    unsigned long newEntries = 0;
    if (oldFirstPicture != nil)
    {
        for (IMMPhoto * photo in organicPhotos)
        {
            if (![photo.date compare:oldFirstPicture])
            {
                break;
            }
            newEntries++;
        }
    }
    else
    {
        newEntries = organicPhotos.count;
    }
    
    NSMutableArray * newPhotos = [[organicPhotos subarrayWithRange:NSMakeRange(0, newEntries)] mutableCopy];

    IMMSearchEngineloading = false;
    return newPhotos;
}

@end
