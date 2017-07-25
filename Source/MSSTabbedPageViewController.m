//
//  MSSTabbedPageViewController.m
//  Paged Tabs Example
//
//  Created by Merrick Sapsford on 27/03/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

#import "MSSTabbedPageViewController.h"
#import "MSSPageViewController+Private.h"
#import "MSSTabNavigationBar+Private.h"
#import "MSSTabBarView+Private.h"
#import <objc/runtime.h>

@interface MSSTabbedPageViewController () <UINavigationControllerDelegate>

#if !defined(MSS_APP_EXTENSIONS)
@property (nonatomic, weak) MSSTabNavigationBar *tabNavigationBar;
#endif

@property (nonatomic, assign) BOOL allowTabBarRequiredCancellation;

@end

@implementation MSSTabbedPageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    MSSTabBarView *tabBarView = [[MSSTabBarView alloc] init];
    self.tabBarView = tabBarView;
    self.pageViewController = [[MSSPageViewController alloc] init];
    self.pageViewController.provideOutOfBoundsUpdates = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransitionInView:self.tabBarView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tabBarView setTabOffset:self.tabBarView.tabOffset];
    }];
}

#pragma mark - Tab bar data source

- (NSInteger)numberOfItemsForTabBarView:(MSSTabBarView *)tabBarView {
    return self.pageViewController.viewControllers.count;
}

- (void)tabBarView:(MSSTabBarView *)tabBarView
       populateTab:(MSSTabBarCollectionViewCell *)tab
           atIndex:(NSInteger)index {
    
}

- (NSInteger)defaultTabIndexForTabBarView:(MSSTabBarView *)tabBarView {
    if (self.pageViewController.currentPage == MSSPageViewControllerPageNumberInvalid) { // return default page if page has not been moved
        return self.pageViewController.defaultPageIndex;
    }
    return self.pageViewController.currentPage;
}

#pragma mark - Tab bar delegate

- (void)tabBarView:(MSSTabBarView *)tabBarView tabSelectedAtIndex:(NSInteger)index {
    if (index != self.pageViewController.currentPage && !self.pageViewController.isAnimatingPageUpdate && index < self.pageViewController.viewControllers.count) {
        self.pageViewController.allowScrollViewUpdates = NO;
        self.pageViewController.userInteractionEnabled = NO;
        
        [self.tabBarView setTabIndex:index animated:YES];
        typeof(self) __weak weakSelf = self;
        [self.pageViewController moveToPageAtIndex:index
                     completion:^(UIViewController *newViewController, BOOL animated, BOOL transitionFinished) {
                         typeof(weakSelf) __strong strongSelf = weakSelf;
                         strongSelf.pageViewController.allowScrollViewUpdates = YES;
                         strongSelf.pageViewController.userInteractionEnabled = YES;
                     }];
    }
}

#pragma mark - Page View Controller delegate

- (void)pageViewController:(MSSPageViewController *)pageViewController
     didScrollToPageOffset:(CGFloat)pageOffset
                 direction:(MSSPageViewControllerScrollDirection)scrollDirection {
    [self.tabBarView setTabOffset:pageOffset];
}

- (void)pageViewController:(MSSPageViewController *)pageViewController
          willScrollToPage:(NSInteger)newPage
               currentPage:(NSInteger)currentPage {
    self.tabBarView.userInteractionEnabled = NO;
}

- (void)pageViewController:(MSSPageViewController *)pageViewController
           didScrollToPage:(NSInteger)page {
    self.pageViewController.allowScrollViewUpdates = YES;
    self.pageViewController.userInteractionEnabled = YES;
    self.tabBarView.userInteractionEnabled = YES;
}

#pragma mark - Navigation Controller delegate

#if !defined(MSS_APP_EXTENSIONS)
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    // Fix for navigation controller swipe back gesture
    // Manually set tab bar to hidden if gesture was cancelled
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled] && self.allowTabBarRequiredCancellation) {
            self.tabNavigationBar.tabBarRequired = NO;
            [self.tabNavigationBar setNeedsLayout];
        }
    }];
}
#endif

@end
