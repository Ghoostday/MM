//
//  IMMOAuthWebView.h
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMOAuthWebView : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView * webView;

@end