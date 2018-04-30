
#import "IMMAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "IMMInstagramEngine.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@implementation IMMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _configManager = [IMMConfigManager sharedInstance];
    NSLog(@"server: %@", _configManager.config[@"server"]);
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    

    [GMSServices provideAPIKey:@"AIzaSyAoYEX1VbHZDKQT9FFgHL64awDvtyVzQQI"];
    
    _searchManager = [IMMSearchManager sharedInstance];
    _searchManager.appBase = _configManager.config[@"server"];
    _searchManager.timeout = (int) [_configManager.config[@"timeout"] integerValue];
    _searchManager.photosNeededToBoost = (int) [_configManager.config[@"photosNeededToBoost"] integerValue];
    _searchManager.maxBoostZones = (int) [_configManager.config[@"maxBoostZones"] integerValue];
    
    _photoManager = [IMMPhotoManager sharedInstance];
    _photoManager.appBase = _configManager.config[@"server"];
    _photoManager.timeout = (int) [_configManager.config[@"timeout"] integerValue];

//  OVERRIDE SEARCH URL FOR MARKETING SCREEN SHOTS
//    IMMInstagramEngine * instagram = [IMMInstagramEngine sharedInstance];
//    instagram.baseSearchUrl = @"http://integrate.innology.fr/moonmasons-server/resources/test/instagram-long.json";
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController * authView = [st instantiateViewControllerWithIdentifier:@"OAuthWebViewNavigator"];
    _searchEngine = [[IMMSearchEngine alloc] initWithAuthView:authView];
    
    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"performFetchWithCompletionHandler");
    NSMutableArray * newPhotos = [_searchEngine organicPhotos:true];
    int status = UIBackgroundFetchResultNoData;
    if (newPhotos.count > 0)
    {
        NSString * message = [NSString stringWithFormat:@"Il ya %lu nouvelles photos dans vos régions alert", (unsigned long)newPhotos.count];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = message;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [UIApplication sharedApplication].applicationIconBadgeNumber = newPhotos.count;
        NSLog(@"Backgroun Fetch: %@", message);
        status = UIBackgroundFetchResultNewData;
    }

    completionHandler(status);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [_searchManager clearCache];
    [_photoManager clearCache];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
