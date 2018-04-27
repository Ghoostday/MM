//
//  IMMSearchResultsHeader.h
//  Moonmasons
//
//  Created by Johan Wiig on 24/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMSearchResultsHeader : UIView

@property (strong, nonatomic) IBOutlet UILabel * label;

- (void) loadState;
- (void) normalState;

@end
