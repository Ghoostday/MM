//
//  IMMSearchResultsHeader.m
//  Moonmasons
//
//  Created by Johan Wiig on 24/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchResultsHeader.h"

@implementation IMMSearchResultsHeader

- (void) loadState
{
    _label.text = @"Chargement...";
}

- (void) normalState
{
    _label.text = @"Tirer pour mettre à jour";
}

@end
