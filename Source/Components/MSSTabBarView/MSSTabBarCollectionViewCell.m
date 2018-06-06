//
//  MSSTabBarCollectionViewCell.m
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 13/01/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

#import "MSSTabBarCollectionViewCell.h"
#import "MSSTabBarCollectionViewCell+Private.h"

@interface MSSTabBarCollectionViewCell () {
    BOOL _isSelected;
}

@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, weak) IBOutlet UIView *textContainerView;
@property (nonatomic, weak) IBOutlet UILabel *textTitleLabel;

@property (nonatomic, weak) IBOutlet UIView *imageContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageImageView;

@property (nonatomic, weak) IBOutlet UIView *imageTextContainerView;
@property (nonatomic, weak) IBOutlet UILabel *imageTextTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageTextImageView;
@property (nonatomic, weak) IBOutlet UIImageView *tabBackgroundView;

@property (nonatomic, weak) IBOutlet UIView *verticalImageTextContainerView;
@property (nonatomic, weak) IBOutlet UILabel *verticalImageTextTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *verticalImageTextDetailTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *verticalImageTextImageView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerViewBottomMargin;

@end

@implementation MSSTabBarCollectionViewCell

#pragma mark - Init


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    _alphaEffectEnabled = YES; // alpha effect enabled by default
}

- (void)prepareForReuse {
	[super prepareForReuse];
	self.verticalImageTextImageView.image = nil;
	self.verticalImageTextImageView.highlightedImage = nil;
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    self.textTitleLabel.text = title;
    self.imageTextTitleLabel.text = title;
	self.verticalImageTextTitleLabel.text = title;
}

- (NSString *)title {
    return self.textTitleLabel.text;
}

-(void)setDetailText:(NSString *)detailText {
	self.verticalImageTextDetailTitleLabel.text = detailText;
}

- (NSString *)detailText {
	return self.verticalImageTextDetailTitleLabel.text;
}

- (void)setImage:(UIImage *)image {
    if (self.tabStyle == MSSTabStyleImage || self.tabStyle == MSSTabStyleImageAndText) {
        self.imageImageView.image = image;
        self.imageTextImageView.image = image;
		self.verticalImageTextImageView.image = image;
    }
}

- (UIImage *)image {
    return self.imageImageView.image;
}

- (UIImage *)highlightedImage {
	return self.imageImageView.highlightedImage;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	if (self.tabStyle == MSSTabStyleImage || self.tabStyle == MSSTabStyleImageAndText) {
		self.imageImageView.highlightedImage = highlightedImage;
		self.imageTextImageView.highlightedImage = highlightedImage;
		self.verticalImageTextImageView.highlightedImage = highlightedImage;
	}
}

static CGFloat const kTableViewCellMinHeight = 44.0f;
static CGFloat const kTableViewCellMaxHeight = 70.0f;

+ (CGFloat)heightForText:(NSString *)aText detailText:(NSString *)detailText width:(CGFloat)width font:(UIFont *)font imageOffset:(CGFloat)imageOffset{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	
	NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
	
	CGRect rect = [aText boundingRectWithSize:CGSizeMake(width - imageOffset, MAXFLOAT)
						 options:NSStringDrawingUsesLineFragmentOrigin
						 attributes:attributes
						 context:nil];
	if (detailText.length > 0) {
		if (CGRectGetHeight(rect) < 22.0f) {
			return kTableViewCellMinHeight;
		}
		else if (CGRectGetHeight(rect) >= 22.0f && CGRectGetHeight(rect) < 48.0f) {
			return CGRectGetHeight(rect) + 22.0f;
		}
		else {
			return kTableViewCellMaxHeight;
		}
	}
	else {
		if (CGRectGetHeight(rect) < 35.0f) {
			return kTableViewCellMinHeight;
		}
		else if (CGRectGetHeight(rect) >= 35.0f && CGRectGetHeight(rect) < 57.0f) {
			return CGRectGetHeight(rect) + 13.0f;
		}
		else {
			return kTableViewCellMaxHeight;
		}
	}
}

#pragma mark - Private

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!_isSelected) {
        self.textTitleLabel.textColor = textColor;
        self.imageTextTitleLabel.textColor = textColor;
		self.verticalImageTextTitleLabel.textColor = textColor;
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    if (_isSelected) {
        self.textTitleLabel.textColor = selectedTextColor;
        self.imageTextTitleLabel.textColor = selectedTextColor;
		self.verticalImageTextTitleLabel.textColor = selectedTextColor;
		self.imageImageView.tintColor = selectedTextColor;
		self.imageTextImageView.tintColor = selectedTextColor;
		self.verticalImageTextImageView.tintColor = selectedTextColor;
    }
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    if (!_isSelected) {
        self.textTitleLabel.font = textFont;
        self.imageTextTitleLabel.font = textFont;
		self.verticalImageTextTitleLabel.font = textFont;
    }
}

- (void)setSelectedTextFont:(UIFont *)selectedTextFont {
    _selectedTextFont = selectedTextFont;
    if (_isSelected) {
        self.textTitleLabel.font = selectedTextFont;
        self.imageTextTitleLabel.font = selectedTextFont;
		self.verticalImageTextTitleLabel.font = selectedTextFont;
    }
}

- (void)setTabStyle:(MSSTabStyle)tabStyle {
    _tabStyle = tabStyle;
    
    switch (tabStyle) {
        case MSSTabStyleImageAndText:
            [self.textContainerView removeFromSuperview];
			[self.imageContainerView removeFromSuperview];
            self.imageTextContainerView.hidden = NO;
            break;
            
        case MSSTabStyleImage:
			[self.textContainerView removeFromSuperview];
            self.imageContainerView.hidden = NO;
            [self.imageTextContainerView removeFromSuperview];
            break;
            
        default:
            self.textContainerView.hidden = NO;
            [self.imageContainerView removeFromSuperview];
            [self.imageTextContainerView removeFromSuperview];
            break;
    }
}

- (void)setContentBottomMargin:(CGFloat)contentBottomMargin {
    self.containerViewBottomMargin.constant = contentBottomMargin;
}

- (void)setTabBackgroundColor:(UIColor *)tabBackgroundColor {
    _tabBackgroundColor = tabBackgroundColor;
    if (!_isSelected) {
        self.backgroundColor = tabBackgroundColor;
    }
}

- (void)setSelectedTabBackgroundColor:(UIColor *)selectedTabBackgroundColor {
    _selectedTabBackgroundColor = selectedTabBackgroundColor;
    if (_isSelected) {
        self.backgroundColor = selectedTabBackgroundColor;
    }
}

- (void)setTabBackgroundViewImage:(UIImage *)tabBackgroundViewImage {
    _tabBackgroundViewImage = tabBackgroundViewImage;
    self.tabBackgroundView.image = self.tabBackgroundViewImage;
}

- (void)setSelectedTabBackgroundViewImage:(UIImage *)selectedTabBackgroundViewImage {
    _selectedTabBackgroundViewImage = selectedTabBackgroundViewImage;
}

- (void)setSelectionProgress:(CGFloat)selectionProgress {
	[self setSelectionProgress:selectionProgress animated:YES];
}

- (void)setSelectionProgress:(CGFloat)selectionProgress animated:(BOOL)animated {
	_selectionProgress = selectionProgress;
	
	[self updateProgressiveAppearance];
	[self updateSelectionAppearanceAnimated:animated];
}

- (void)setAlphaEffectEnabled:(BOOL)alphaEffectEnabled {
    _alphaEffectEnabled = alphaEffectEnabled;
    if (alphaEffectEnabled) {
        [self updateProgressiveAppearance];
    } else {
        self.textTitleLabel.alpha = 1.0f;
        self.imageTextTitleLabel.alpha = 1.0f;
		self.verticalImageTextImageView.alpha = 1.0f;
    }
}

#pragma mark - Internal

- (void)updateProgressiveAppearance {
    switch (self.tabStyle) {
        case MSSTabStyleText:
        case MSSTabStyleImageAndText:
            if (self.alphaEffectEnabled) {
                self.textTitleLabel.alpha = self.selectionProgress;
                self.imageTextTitleLabel.alpha = self.selectionProgress;
				self.verticalImageTextTitleLabel.alpha = self.selectionProgress;
            }
            break;
            
        default:
            break;
    }
}

- (void)updateSelectionAppearanceAnimated:(BOOL)animated {
    BOOL isSelected = (self.selectionProgress == 1.0f);
    if (_isSelected != isSelected) { // update selected state
        
        if (self.selectedTextFont || self.selectedTextColor) {
            [UIView transitionWithView:self
                              duration:animated ? 0.2f : 0.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:
             ^{
                 if (self.selectedTextColor) {
                     UIColor *textColor = isSelected ? self.selectedTextColor : self.textColor;
                     self.textTitleLabel.textColor = textColor;
                     self.imageTextTitleLabel.textColor = textColor;
					 self.verticalImageTextTitleLabel.textColor = textColor;
                 } else {
                     self.textTitleLabel.textColor = self.textColor;
                     self.imageTextTitleLabel.textColor = self.textColor;
					 self.verticalImageTextTitleLabel.textColor = self.textColor;
                 }
                 
                 if (self.selectedTextFont) {
                     UIFont *textFont = isSelected ? self.selectedTextFont : self.textFont;
                     self.textTitleLabel.font = textFont;
                     self.imageTextTitleLabel.font = textFont;
					 self.verticalImageTextTitleLabel.font = textFont;
                 } else {
                     self.textTitleLabel.font = self.textFont;
                     self.imageTextTitleLabel.font = self.textFont;
					 self.verticalImageTextTitleLabel.font = self.textFont;
                 }
                 
                 if (self.selectedTabBackgroundColor) {
                     self.backgroundColor = isSelected ? self.selectedTabBackgroundColor : self.tabBackgroundColor;
                 } else {
                     self.backgroundColor = self.tabBackgroundColor;
                 }
                 if (self.selectedTabBackgroundViewImage) {
                     self.tabBackgroundView.image = isSelected ? self.selectedTabBackgroundViewImage : self.tabBackgroundViewImage;
                 } else {
                     self.tabBackgroundView.image = self.tabBackgroundViewImage;
                 }
				 
				 if (self.highlightedImage) {
					 self.verticalImageTextImageView.image = isSelected ? self.highlightedImage : self.image;
				 }
             } completion:nil];
        }
        
        _isSelected = isSelected;
        self.selected = isSelected;
		self.imageImageView.highlighted = isSelected;
		self.imageTextImageView.highlighted = isSelected;
		self.verticalImageTextImageView.highlighted = isSelected;
    }
}

@end
