//
//  MSSTabBarCollectionViewCell.h
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 13/01/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSTabStyle.h"

@interface MSSTabBarCollectionViewCell : UICollectionViewCell

/* A stack with a horizontal axis is a row of arrangedSubviews,
 and a stack with a vertical axis is a column of arrangedSubviews.
 */
@property (nonatomic) UILayoutConstraintAxis axis UI_APPEARANCE_SELECTOR;
/**
 The style of the tab.
 */
@property (nonatomic, assign, readonly) MSSTabStyle tabStyle;
/**
 The image displayed in the tab cell.
 
 NOTE - only visible when using MSSTabStyleImage.
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 The image displayed in the tab of selected cell.
 */
@property (nonatomic, strong, nullable) UIImage *highlightedImage;

/**
 The text displayed in the tab cell.
 
 NOTE - only visible when using MSSTabStyleText.
 */
@property (nonatomic, copy, nullable) NSString *title;

+ (CGFloat)heightForText:(NSString *)aText detailText:(NSString *)detailText width:(CGFloat)width font:(UIFont *)font;

@end
