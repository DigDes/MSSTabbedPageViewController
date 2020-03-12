//
//  TabViewController.h
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 24/12/2015.
//  Copyright © 2015 Merrick Sapsford. All rights reserved.
//

#import <MSSTabbedPageViewController/MSSTabbedPageViewController.h>
#import <UIKit/UIKit.h>
#import "TabControllerStyle.h"

@interface TabViewController : MSSTabbedPageViewController

@property (nonatomic, strong) TabControllerStyle *style;

@end
