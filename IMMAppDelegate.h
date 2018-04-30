

#import <UIKit/UIKit.h>
#import "IMMSearchEngine.h"
#import "IMMSearchManager.h"
#import "IMMPhotoManager.h"
#import "IMMConfigManager.h"

@interface IMMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property IMMSearchEngine * searchEngine;
@property IMMSearchManager * searchManager;
@property IMMPhotoManager * photoManager;
@property IMMConfigManager * configManager;

@end
