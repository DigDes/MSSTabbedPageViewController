//
//  MSSTabbedPageViewController.h
//  Paged Tabs Example
//
//  Created by Merrick Sapsford on 27/03/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

#import "MSSPageViewController.h"
#import "MSSTabNavigationBar.h"

@interface MSSTabbedPageViewController : UIViewController <MSSTabBarViewDataSource, MSSTabBarViewDelegate>

/**
 The tab bar view.
 */
@property (nonatomic, strong, nullable) MSSTabBarView *tabBarView;
@property (nonatomic, strong, nullable) MSSPageViewController *pageViewController;

@end
