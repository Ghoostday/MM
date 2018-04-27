//
//  IMMSearchEngine.h
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMProviderEngine.h"
#import "IMMSearchProvider.h"

@interface IMMSearchEngine : NSObject

@property NSMutableArray * photos;
@property UIViewController * authView;

- (id)initWithAuthView:(UIViewController*)authView;
- (NSMutableArray*) organicPhotos;
- (NSMutableArray*) organicPhotos:(BOOL)alert;

@end
