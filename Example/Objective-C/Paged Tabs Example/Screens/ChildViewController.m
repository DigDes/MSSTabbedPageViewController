//
//  ViewController.m
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 24/12/2015.
//  Copyright © 2015 Merrick Sapsford. All rights reserved.
//

#import "ChildViewController.h"
#import <MSSTabbedPageViewController/MSSTabbedPageViewController.h>

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleLabel.text = [NSString stringWithFormat:@"Page %i", (int)(self.pageIndex + 1)];
}

@end
