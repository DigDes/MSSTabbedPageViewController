//
//  MSSTabBarView.m
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 13/01/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

#import "MSSTabBarView.h"
#import "MSSTabBarView+Private.h"
#import "UIView+MSSAutoLayout.h"
#import "MSSTabBarCollectionViewCell+Private.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static NSString *const MSSTabBarViewCellIdentifier = @"MSSTabBarCollectionViewCell";
static NSString *const MSSTabBarViewTextCellIdentifier = @"MSSTabBarTextCollectionViewCell";

// defaults
CGFloat const MSSTabBarViewDefaultHeight = 44.0f;

static CGFloat const MSSTabBarViewDefaultCellWidthForVerticalAxis = 222.0f;
static CGFloat const MSSTabBarViewDefaultCellWidthForHorisontalAxis = 60.0f;
static CGFloat const MSSTabBarViewDefaultTabIndicatorHeight = 2.0f;
static CGFloat const MSSTabBarViewDefaultTabPadding = 8.0f;
static CGFloat const MSSTabBarViewDefaultTabUnselectedAlpha = 0.3f;
static CGFloat const MSSTabBarViewDefaultHorizontalContentInset = 8.0f;
static NSString *const MSSTabBarViewDefaultTabTitleFormat = @"Tab %li";
static BOOL const MSSTabBarViewDefaultScrollEnabled = YES;

static NSInteger const MSSTabBarViewDefaultMaxDistributedTabs = 5;
static CGFloat const MSSTabBarViewTabTransitionSnapRatio = 0.5f;

static CGFloat const MSSTabBarViewTabOffsetInvalid = -1.0f;

@interface MSSTabBarView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *tabTitles;
@property (nonatomic, assign) NSInteger tabCount;
@property (nonatomic, assign) NSInteger maxDistributedTabs;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) MSSTabBarCollectionViewCell *selectedCell;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIView *indicatorContainer;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *verticalSeparatorView;
@property (nonatomic, assign) CGFloat lineIndicatorHeight;
@property (nonatomic, assign) CGFloat lineIndicatorInset;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat previousTabOffset;
@property (nonatomic, assign) NSInteger defaultTabIndex;

@property (nonatomic, assign) CGFloat tabDeselectedAlpha;

@property (nonatomic, assign) BOOL hasRespectedDefaultTabIndex;

@property (nonatomic, assign) BOOL hasScrolledCollectionView;

@property (nonatomic, assign) BOOL animateDataSourceTransition;

@property (nonatomic, strong) MSSTabBarCollectionViewCell *sizingCell;

@end

@implementation MSSTabBarView

@synthesize contentInset = _contentInset;

#pragma mark - Init

- (instancetype)init {
	if (self = [super init]) {
		[self baseInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if ([super initWithCoder:coder]) {
		[self baseInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ([super initWithFrame:frame]) {
		[self baseInit];
	}
	return self;
}

- (instancetype)initWithHeight:(CGFloat)height {
	if (self = [super init]) {
		_height = height;
		[self baseInit];
	}
	return self;
}

- (void)baseInit {
	
	// General
	_tabPadding = MSSTabBarViewDefaultTabPadding;
	CGFloat horizontalInset = MSSTabBarViewDefaultHorizontalContentInset;
	_contentInset = UIEdgeInsetsMake(0.0f, horizontalInset, 0.0f, horizontalInset);
	_tabOffset = MSSTabBarViewTabOffsetInvalid;
	_maxDistributedTabs = MSSTabBarViewDefaultMaxDistributedTabs;
	
	if (_height == 0.0f) {
		_height = MSSTabBarViewDefaultHeight;
	}
	
	// Collection view
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	_collectionView.prefetchingEnabled = NO;
	self.scrollEnabled = MSSTabBarViewDefaultScrollEnabled;
	_tabTextColor = [UIColor blackColor];
	
	// Tab indicator
	_indicatorContainer = [UIView new];
	_indicatorStyle = MSSIndicatorStyleLine;
	_indicatorContainer.userInteractionEnabled = NO;
	_indicatorAttributes = @{
			MSSTabIndicatorLineHeight: @(MSSTabBarViewDefaultTabIndicatorHeight), NSForegroundColorAttributeName: self.tintColor
	};
	
	_separatorView = [UIView new];
	_separatorView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
	_verticalSeparatorView = [UIView new];
	_verticalSeparatorView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
}

#pragma mark - Lifecycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	if (!self.separatorView.superview) {
		UIView *subview = self.separatorView;
		[self addSubview:self.separatorView];
		subview.translatesAutoresizingMaskIntoConstraints = NO;
		NSDictionary *views = NSDictionaryOfVariableBindings(subview);
		
		NSString *verticalConstraints = [NSString stringWithFormat:@"V:[subview(1)]|"];
		NSString *horizontalConstraints = [NSString stringWithFormat:@"H:|[subview]|"];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:0 metrics:nil views:views]];
	}
	if (!self.verticalSeparatorView.superview) {
		UIView *subview = self.verticalSeparatorView;
		[self addSubview:self.verticalSeparatorView];
		subview.translatesAutoresizingMaskIntoConstraints = NO;
		NSDictionary *views = NSDictionaryOfVariableBindings(subview);
		
		NSString *verticalConstraints = [NSString stringWithFormat:@"H:[subview(1)]|"];
		NSString *horizontalConstraints = [NSString stringWithFormat:@"V:|[subview]|"];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:0 metrics:nil views:views]];
	}
	if (!self.collectionView.superview) {
		[self registerCellForTabStyle:self.tabStyle];
		[self mss_addExpandingSubview:self.collectionView];
		self.collectionView.contentInset = self.contentInset;
		self.collectionView.backgroundColor = [UIColor clearColor];
		self.collectionView.showsHorizontalScrollIndicator = NO;
	}
	if (!self.indicatorContainer.superview) {
		[self.collectionView addSubview:self.indicatorContainer];
		[self updateIndicatorForStyle:self.indicatorStyle];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self updateDistributedCellsCount];
	if (self.tabOffset == MSSTabBarViewTabOffsetInvalid) {
		[self updateTabBarForTabIndex:self.defaultTabIndex];
		[self updateTabBarForTabOffset:self.defaultTabIndex];
	}
	else {
		[self updateTabBarForTabIndex:self.tabOffset];
		[self updateTabBarForTabOffset:self.tabOffset];
	}
	
	// if default tab has not yet been displayed
	if (self.tabCount > 0 && !self.selectedCell) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.defaultTabIndex inSection:0];
		[self.collectionView scrollToItemAtIndexPath:indexPath
							 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
							 animated:self.animateDataSourceTransition];
	}
}

#pragma mark - Collection View data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self evaluateDataSource] + self.numberOfInsertedTabs;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MSSTabBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSSTabBarViewCellIdentifier forIndexPath:indexPath];
	[self updateCellAppearance:cell];
	
	// default contents
	cell.tabStyle = self.tabStyle;
	cell.title = [self titleAtIndex:indexPath.row];
	
	// populate cell
	if ([self.dataSource respondsToSelector:@selector(tabBarView:populateTab:atIndex:)]) {
		[self.dataSource tabBarView:self populateTab:cell atIndex:indexPath.item];
	}
	
	cell.selectionProgress = self.tabDeselectedAlpha;
	
	if ((!self.hasRespectedDefaultTabIndex && indexPath.row == self.defaultTabIndex) ||
		([self.selectedIndexPath isEqual:indexPath] && self.tabOffset == MSSTabBarViewTabOffsetInvalid && !self.hasScrolledCollectionView)) {
		_hasRespectedDefaultTabIndex = YES;
		[self setTabCellActive:cell indexPath:indexPath];
	}
	else if ([self.selectedIndexPath isEqual:indexPath]) {
		[cell setSelectionProgress:1.0f animated:NO];
	}
	
	return cell;
}

#pragma mark - Collection View delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGSize fittingSize = UILayoutFittingCompressedSize;
	CGSize cellSize = CGSizeZero;
	
	if (self.axis == UILayoutConstraintAxisHorizontal) {
		if (self.sizingStyle == MSSTabSizingStyleDistributed && self.tabCount <= self.maxDistributedTabs) { // distributed in frame
			
			CGFloat contentInsetTotal = self.contentInset.left + self.contentInset.right;
			CGFloat totalSpacing = collectionViewLayout.minimumInteritemSpacing * (self.tabCount - 1);
			CGFloat totalWidth = CGRectGetWidth(collectionView.bounds) - contentInsetTotal - totalSpacing;
			
			return CGSizeMake(totalWidth / self.tabCount, CGRectGetHeight(collectionView.bounds));
		}
		else { // wrap tab contents
			// update sizing cell with population
			CGSize requiredSize = [self getSizeToFitCellSize:collectionView forIndex:indexPath.item];
			
			cellSize = requiredSize;
		}
	}
	else {
		if ([self.dataSource respondsToSelector:@selector(tabBarView:populateTab:atIndex:)]) {
			[self.dataSource tabBarView:self populateTab:self.sizingCell atIndex:indexPath.item];
		}
		else {
			self.sizingCell.title = [self titleAtIndex:indexPath.row];
		}
		
		[self.sizingCell setNeedsLayout];
		[self.sizingCell layoutIfNeeded];
		
		fittingSize.width = MSSTabBarViewDefaultCellWidthForVerticalAxis;
		
		CGSize requiredSize = [self.sizingCell systemLayoutSizeFittingSize:fittingSize
											   withHorizontalFittingPriority:UILayoutPriorityRequired
											   verticalFittingPriority:UILayoutPriorityDefaultLow];
		requiredSize.width = CGRectGetWidth(collectionView.bounds);
        if (_tabHeight) {
            requiredSize.height = _tabHeight;
        }
        else {
            requiredSize.height = [MSSTabBarCollectionViewCell heightForText:self.sizingCell.title
                                                               detailText:@""
                                                               width:fittingSize.width
                                                               font:[UIFont systemFontOfSize:14.0f]
                                                               imageOffset:44.0f];
        }
		cellSize = requiredSize;
	}
	
	return cellSize;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return !_animatingTabChange;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(tabBarView:tabSelectedAtIndex:)]) {
		[self.delegate tabBarView:self tabSelectedAtIndex:indexPath.row];
	}
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _collectionView.allowsSelection = NO;
    _hasScrolledCollectionView = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _collectionView.allowsSelection = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_collectionView selectItemAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Public

- (void)setTabPadding:(CGFloat)tabPadding {
	_tabPadding = tabPadding;
	[self reloadData];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
	_contentInset = contentInset;
	
	// add selection indicator height to bottom of collection view inset
	CGFloat indicatorHeight;
	if (self.indicatorAttributes) {
		indicatorHeight = [self.indicatorAttributes[MSSTabIndicatorLineHeight] floatValue];
	}
	else {
		indicatorHeight = self.selectionIndicatorHeight;
	}
	contentInset.bottom += indicatorHeight;
	
	self.collectionView.contentInset = contentInset;
}

- (UIEdgeInsets)contentInset {
	return self.axis == UILayoutConstraintAxisHorizontal ? _contentInset : UIEdgeInsetsZero;
}

- (void)setTabIndex:(NSInteger)index animated:(BOOL)animated {
	if (animated) {
		self.userInteractionEnabled = NO;
		_animatingTabChange = YES;
		[UIView animateWithDuration:0.25f animations:^{
			[self updateTabBarForTabIndex:index];
		} completion:^(BOOL finished) {
			_animatingTabChange = NO;
			self.userInteractionEnabled = YES;
		}];
	}
	else {
		[self updateTabBarForTabIndex:index];
	}
}

- (void)setTabOffset:(CGFloat)offset {
	_previousTabOffset = _tabOffset;
	_tabOffset = offset;
	[self updateTabBarForTabOffset:offset];
}

- (void)setDefaultTabIndex:(NSInteger)defaultTabIndex {
	assert(defaultTabIndex != NSNotFound);
	if (self.tabOffset == MSSTabBarViewTabOffsetInvalid) { // only allow default to be set if tab is runtime default
		self.hasRespectedDefaultTabIndex = NO;
		_defaultTabIndex = defaultTabIndex;
	}
}

- (void)setTabIndicatorColor:(UIColor *)tabIndicatorColor {
	_tabIndicatorColor = tabIndicatorColor;
	if (self.indicatorStyle == MSSIndicatorStyleLine) {
		self.indicatorView.backgroundColor = tabIndicatorColor;
	}
}

- (void)setSelectionIndicatorHeight:(CGFloat)selectionIndicatorHeight {
	self.lineIndicatorHeight = selectionIndicatorHeight;
}

- (void)setTabTextColor:(UIColor *)tabTextColor {
	_tabTextColor = tabTextColor;
	[self reloadData];
}

- (void)setTabTextFont:(UIFont *)tabTextFont {
	_tabTextFont = tabTextFont;
	[self reloadData];
}

- (void)setBackgroundView:(UIView *)backgroundView {
	_backgroundView = backgroundView;
	[self mss_addExpandingSubview:backgroundView];
	[self sendSubviewToBack:backgroundView];
}

- (void)setDataSource:(id <MSSTabBarViewDataSource>)dataSource {
	self.animateDataSourceTransition = NO;
	[self doSetDataSource:dataSource];
}

- (void)setDataSource:(id <MSSTabBarViewDataSource>)dataSource animated:(BOOL)animated {
	self.animateDataSourceTransition = animated;
	[self doSetDataSource:dataSource];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	self.collectionView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
	return self.collectionView.scrollEnabled;
}

- (void)setUserScrollEnabled:(BOOL)userScrollEnabled {
	self.scrollEnabled = userScrollEnabled;
}

- (BOOL)userScrollEnabled {
	return self.scrollEnabled;
}

- (void)setAxis:(UILayoutConstraintAxis)axis {
	_axis = axis;
	self.indicatorContainer.hidden = _axis == UILayoutConstraintAxisVertical;
	self.separatorView.hidden = _axis == UILayoutConstraintAxisVertical;
	self.verticalSeparatorView.hidden = _axis == UILayoutConstraintAxisHorizontal;
	self.collectionView.contentInset = self.contentInset;
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
	layout.minimumLineSpacing = _axis == UILayoutConstraintAxisHorizontal ? 10.0f : 0.0f;
	layout.scrollDirection = _axis == UILayoutConstraintAxisHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
	[layout invalidateLayout];
}

- (void)setSizingStyle:(MSSTabSizingStyle)sizingStyle {
	if ((sizingStyle == MSSTabSizingStyleDistributed && self.tabCount <= MSSTabBarViewDefaultMaxDistributedTabs) || sizingStyle == MSSTabSizingStyleSizeToFit) {
		_sizingStyle = sizingStyle;
		[self reloadData];
	}
	else {
		NSLog(@"%@ - Distributed tab spacing is unavailable when using a tab count greater than %li", NSStringFromClass([self class]), (long) MSSTabBarViewDefaultMaxDistributedTabs);
	}
}

- (void)setTabStyle:(MSSTabStyle)tabStyle {
	_tabStyle = tabStyle;
	[self registerCellForTabStyle:tabStyle];
	[self reloadData];
}

- (void)registerCellForTabStyle:(MSSTabStyle)tabStyle {
	UINib *cellNib;
	if (tabStyle == MSSTabStyleText) {
		cellNib = [UINib nibWithNibName:MSSTabBarViewTextCellIdentifier bundle:[NSBundle bundleForClass:[MSSTabBarCollectionViewCell class]]];
		[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:MSSTabBarViewCellIdentifier];
	}
	else {
		cellNib = [UINib nibWithNibName:MSSTabBarViewCellIdentifier bundle:[NSBundle bundleForClass:[MSSTabBarCollectionViewCell class]]];
		[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:MSSTabBarViewCellIdentifier];
	}
	self.sizingCell = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
}

- (void)setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];
	self.tabIndicatorColor = tintColor;
}

- (void)setTransitionStyle:(MSSTabTransitionStyle)transitionStyle {
	self.selectionIndicatorTransitionStyle = transitionStyle;
	self.tabTransitionStyle = transitionStyle;
}

- (void)setTabAttributes:(NSDictionary<NSString *, id> *)tabAttributes {
	_tabAttributes = tabAttributes;
	[self reloadData];
}

- (void)setSelectionIndicatorTransitionStyle:(MSSTabTransitionStyle)selectionIndicatorTransitionStyle {
	self.indicatorTransitionStyle = selectionIndicatorTransitionStyle;
}

- (void)setIndicatorAttributes:(NSDictionary<NSString *, id> *)indicatorAttributes {
	_indicatorAttributes = indicatorAttributes;
	[self updateIndicatorAppearance];
}

- (void)setIndicatorStyle:(MSSIndicatorStyle)indicatorStyle {
	if (indicatorStyle != _indicatorStyle) {
		_indicatorStyle = indicatorStyle;
		[self updateIndicatorForStyle:indicatorStyle];
	}
}

- (void)setLineIndicatorHeight:(CGFloat)lineIndicatorHeight {
	if (lineIndicatorHeight != _lineIndicatorHeight) {
		_lineIndicatorHeight = lineIndicatorHeight;
		[self updateIndicatorFrames];
	}
}

- (void)reloadData {
	if (self.tabOffset == MSSTabBarViewTabOffsetInvalid) {
		_hasRespectedDefaultTabIndex = NO;
	}
	[self.collectionView reloadData];
    _hasScrolledCollectionView = NO;
}

- (void)deleteAndInsertTabsAtIndexPaths:(NSArray *)itemPaths {
    [self.collectionView performBatchUpdates:^{
        if (self.isExpanded) {
            self.isExpanded = NO;
            [self.collectionView deleteItemsAtIndexPaths:itemPaths];
        } else {
            self.isExpanded = YES;
            [self.collectionView insertItemsAtIndexPaths:itemPaths];
        }
    } completion:nil];
}


#pragma mark - Tab Bar State

- (void)updateTabBarForTabOffset:(CGFloat)tabOffset {
	
	// calculate the percentage progress of the current tab transition
	float integral;
	CGFloat progress = (CGFloat) modff(tabOffset, &integral);
	BOOL isBackwards = !(tabOffset >= self.previousTabOffset);
	
	if (tabOffset <= 0.0f) { // stick at bottom of tab bar
		
		MSSTabBarCollectionViewCell *firstTabCell = [self collectionViewCellAtTabIndex:0];
		[self updateTabsWithCurrentTabCell:firstTabCell nextTabCell:firstTabCell progress:1.0f backwards:NO];
		[self updateIndicatorViewWithCurrentTabCell:firstTabCell nextTabCell:firstTabCell progress:1.0f axis:self.axis];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self setTabCellsInactiveExceptTabIndex:indexPath.row];
        [self setTabCellActive:firstTabCell indexPath:indexPath];
        [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
	}
	else if (tabOffset >= self.tabCount - 1) { // stick at top of tab bar
		
		MSSTabBarCollectionViewCell *lastTabCell = [self collectionViewCellAtTabIndex:self.tabCount - 1];
		[self updateTabsWithCurrentTabCell:lastTabCell nextTabCell:lastTabCell progress:1.0f backwards:NO];
		[self updateIndicatorViewWithCurrentTabCell:lastTabCell nextTabCell:lastTabCell progress:1.0f axis:self.axis];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tabCount - 1 inSection:0];
        [self setTabCellsInactiveExceptTabIndex:indexPath.row];
        [self setTabCellActive:lastTabCell indexPath:indexPath];
        [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
	}
	else { // update as required
		if (progress != 0.0f) {
			
			// get the current and next tab cells
			NSInteger currentTabIndex = isBackwards ? ceil(tabOffset) : floor(tabOffset);
			NSInteger nextTabIndex = MAX(0, MIN(self.tabCount - 1, isBackwards ? floor(tabOffset) : ceil(tabOffset)));
			
			MSSTabBarCollectionViewCell *currentTabCell = [self collectionViewCellAtTabIndex:currentTabIndex];
			MSSTabBarCollectionViewCell *nextTabCell = [self collectionViewCellAtTabIndex:nextTabIndex];
			
			// update tab bar components
			if (currentTabCell != nextTabCell && (currentTabCell && nextTabCell)) {
				[self updateTabsWithCurrentTabCell:currentTabCell nextTabCell:nextTabCell progress:progress backwards:isBackwards];
				[self updateIndicatorViewWithCurrentTabCell:currentTabCell nextTabCell:nextTabCell progress:progress axis:self.axis];
			}
		}
		else { // finished update - on a tab cell
			
			NSInteger index = floor(tabOffset);
			MSSTabBarCollectionViewCell *selectedCell = [self collectionViewCellAtTabIndex:index];
			NSIndexPath *indexPath = [self.collectionView indexPathForCell:selectedCell];
			
			if (selectedCell && indexPath) {
                [self setTabCellsInactiveExceptTabIndex:indexPath.row];
                [self setTabCellActive:selectedCell indexPath:indexPath];
                [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
			}
		}
	}
}

- (void)updateTabBarForTabIndex:(NSInteger)tabIndex {
	MSSTabBarCollectionViewCell *cell = [self collectionViewCellAtTabIndex:tabIndex];
	if (cell) {
		
		// update tab offsets
		_previousTabOffset = _tabOffset;
		_tabOffset = tabIndex;
		
		// update tab bar cells
		[self setTabCellsInactiveExceptTabIndex:tabIndex];
		[self setTabCellActive:cell indexPath:[NSIndexPath indexPathForItem:tabIndex inSection:0]];
	}
}

- (void)setTabCellsInactiveExceptTabIndex:(NSInteger)index {
	for (NSInteger item = 0; item < self.tabCount; item++) {
		if (item != index) {
			MSSTabBarCollectionViewCell *cell = [self collectionViewCellAtTabIndex:item];
			[self setTabCellInactive:cell];
		}
	}
}

- (void)setTabCellActive:(MSSTabBarCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	_selectedCell = cell;
	_selectedIndexPath = indexPath;
	
	cell.selectionProgress = 1.0f;
	
	if (self.animateDataSourceTransition) {
		[UIView animateWithDuration:0.25f animations:^{
			[self updateIndicatorViewFrameWithXOrigin:cell.frame.origin.x andWidth:cell.frame.size.width accountForPadding:YES axis:self.axis];
		}];
	}
	else {
		CGFloat origin = self.axis == UILayoutConstraintAxisVertical ? cell.frame.origin.y : cell.frame.origin.x;
		CGFloat size = self.axis == UILayoutConstraintAxisVertical ? cell.frame.size.height : cell.frame.size.width;
		[self updateIndicatorViewFrameWithXOrigin:origin andWidth:size accountForPadding:YES axis:self.axis];
	}
}

- (void)setTabCellInactive:(MSSTabBarCollectionViewCell *)cell {
	cell.selectionProgress = self.tabDeselectedAlpha;
}

- (void)updateTabsWithCurrentTabCell:(MSSTabBarCollectionViewCell *)currentTabCell nextTabCell:(MSSTabBarCollectionViewCell *)nextTabCell progress:(CGFloat)progress backwards:(BOOL)isBackwards {
	
	// Calculate updated alpha values for tabs
	progress = isBackwards ? 1.0f - progress : progress;
	
	if (self.tabTransitionStyle == MSSTabTransitionStyleProgressive) { // progressive
		
		CGFloat unselectedAlpha = self.tabDeselectedAlpha;
		CGFloat alphaDiff = (1.0f - unselectedAlpha) * progress;
		CGFloat nextAlpha = unselectedAlpha + alphaDiff;
		CGFloat currentAlpha = 1.0f - alphaDiff;
		
		currentTabCell.selectionProgress = currentAlpha;
		nextTabCell.selectionProgress = nextAlpha;
	}
	else { // snap
		
		CGFloat currentAlpha = (progress > MSSTabBarViewTabTransitionSnapRatio) ? self.tabDeselectedAlpha : 1.0f;
		CGFloat targetAlpha = (progress > MSSTabBarViewTabTransitionSnapRatio) ? 1.0f : self.tabDeselectedAlpha;
		
		BOOL requiresUpdate = (nextTabCell.selectionProgress != targetAlpha);
		if (requiresUpdate) {
			[UIView animateWithDuration:0.25f animations:^{
				currentTabCell.selectionProgress = currentAlpha;
				nextTabCell.selectionProgress = targetAlpha;
			}];
		}
	}
}

- (void)updateIndicatorViewWithCurrentTabCell:(MSSTabBarCollectionViewCell *)currentTabCell nextTabCell:(MSSTabBarCollectionViewCell *)nextTabCell progress:(CGFloat)progress axis:(UILayoutConstraintAxis)axis {
	if (self.tabCount == 0) {
		return;
	}
	if (axis == UILayoutConstraintAxisVertical) {
		// calculate the upper and lower x origins for cells
		CGFloat upperXPos = MAX(nextTabCell.frame.origin.y, currentTabCell.frame.origin.y);
		CGFloat lowerXPos = MIN(nextTabCell.frame.origin.y, currentTabCell.frame.origin.y);
		
		// swap cells according to which has lowest X origin
		BOOL backwards = (nextTabCell.frame.origin.y == lowerXPos);
		if (backwards) {
			MSSTabBarCollectionViewCell *temp = nextTabCell;
			nextTabCell = currentTabCell;
			currentTabCell = temp;
		}
		
		CGFloat newX = 0.0f;
		CGFloat newWidth = 0.0f;
		
		if (self.indicatorTransitionStyle == MSSTabTransitionStyleProgressive) {
			
			// calculate width difference
			CGFloat currentTabWidth = currentTabCell.frame.size.height;
			CGFloat nextTabWidth = nextTabCell.frame.size.height;
			CGFloat widthDiff = (nextTabWidth - currentTabWidth) * progress;
			
			// calculate new frame for indicator
			newX = lowerXPos + ((upperXPos - lowerXPos) * progress);
			newWidth = currentTabWidth + widthDiff;
			
			[self updateIndicatorViewFrameWithXOrigin:newX andWidth:newWidth accountForPadding:YES axis:self.axis];
		}
		else if (self.indicatorTransitionStyle == MSSTabTransitionStyleSnap) {
			
			MSSTabBarCollectionViewCell *cell = progress > MSSTabBarViewTabTransitionSnapRatio ? nextTabCell : currentTabCell;
			
			newX = cell.frame.origin.y;
			newWidth = cell.frame.size.height;
			
			BOOL requiresUpdate = self.indicatorContainer.frame.origin.y != newX;
			if (requiresUpdate) {
				[UIView animateWithDuration:0.25f animations:^{
					[self updateIndicatorViewFrameWithXOrigin:newX andWidth:newWidth accountForPadding:YES axis:self.axis];
				}];
			}
		}
	}
	else {
		// calculate the upper and lower x origins for cells
		CGFloat upperXPos = MAX(nextTabCell.frame.origin.x, currentTabCell.frame.origin.x);
		CGFloat lowerXPos = MIN(nextTabCell.frame.origin.x, currentTabCell.frame.origin.x);
		
		// swap cells according to which has lowest X origin
		BOOL backwards = (nextTabCell.frame.origin.x == lowerXPos);
		if (backwards) {
			MSSTabBarCollectionViewCell *temp = nextTabCell;
			nextTabCell = currentTabCell;
			currentTabCell = temp;
		}
		
		CGFloat newX = 0.0f;
		CGFloat newWidth = 0.0f;
		
		if (self.indicatorTransitionStyle == MSSTabTransitionStyleProgressive) {
			
			// calculate width difference
			CGFloat currentTabWidth = currentTabCell.frame.size.width;
			CGFloat nextTabWidth = nextTabCell.frame.size.width;
			CGFloat widthDiff = (nextTabWidth - currentTabWidth) * progress;
			
			// calculate new frame for indicator
			newX = lowerXPos + ((upperXPos - lowerXPos) * progress);
			newWidth = currentTabWidth + widthDiff;
			
			[self updateIndicatorViewFrameWithXOrigin:newX andWidth:newWidth accountForPadding:YES axis:self.axis];
		}
		else if (self.indicatorTransitionStyle == MSSTabTransitionStyleSnap) {
			
			MSSTabBarCollectionViewCell *cell = progress > MSSTabBarViewTabTransitionSnapRatio ? nextTabCell : currentTabCell;
			
			newX = cell.frame.origin.x;
			newWidth = cell.frame.size.width;
			
			BOOL requiresUpdate = self.indicatorContainer.frame.origin.x != newX;
			if (requiresUpdate) {
				[UIView animateWithDuration:0.25f animations:^{
					[self updateIndicatorViewFrameWithXOrigin:newX andWidth:newWidth accountForPadding:YES axis:self.axis];
				}];
			}
		}
	}
}

- (void)updateIndicatorViewFrameWithXOrigin:(CGFloat)xOrigin andWidth:(CGFloat)width accountForPadding:(BOOL)padding axis:(UILayoutConstraintAxis)axis {
	if (self.tabCount == 0) {
		return;
	}
	if (padding) {
		CGFloat tabInternalPadding = self.tabPadding;
		width -= tabInternalPadding;
		xOrigin += (tabInternalPadding / 2.0f);
	}
	
	if (axis == UILayoutConstraintAxisVertical) {
		self.indicatorContainer.frame = CGRectMake(0.0f, xOrigin, CGRectGetWidth(self.bounds), width);
	}
	else {
		self.indicatorContainer.frame = CGRectMake(xOrigin, 0.0f, width, CGRectGetHeight(self.bounds));
	}
	
	[self updateIndicatorFrames];
	[self updateCollectionViewScrollOffset];
}

- (void)updateCollectionViewScrollOffset {
	if (self.sizingStyle != MSSTabSizingStyleDistributed || self.tabCount > MSSTabBarViewDefaultMaxDistributedTabs) {
		if (self.axis == UILayoutConstraintAxisVertical) {
			// scroll collection view to center selection indicator if possible
			CGFloat collectionViewHeight = self.collectionView.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
			CGFloat scrollViewY = MAX(0, self.indicatorContainer.center.y - (collectionViewHeight / 2.0f));
			[self.collectionView scrollRectToVisible:CGRectMake(self.collectionView.frame.origin.x, scrollViewY, self.collectionView.frame.size.width, collectionViewHeight)
								 animated:NO];
		}
		else {
			// scroll collection view to center selection indicator if possible
			CGFloat collectionViewWidth = self.collectionView.bounds.size.width - self.contentInset.left - self.contentInset.right;
			CGFloat scrollViewX = MAX(0, self.indicatorContainer.center.x - (collectionViewWidth / 2.0f));
			[self.collectionView scrollRectToVisible:CGRectMake(scrollViewX, self.collectionView.frame.origin.y, collectionViewWidth, self.collectionView.frame.size.height)
								 animated:NO];
		}
	}
}

- (MSSTabBarCollectionViewCell *)collectionViewCellAtTabIndex:(NSInteger)tabIndex {
	if (tabIndex >= 0 && tabIndex < self.tabCount) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tabIndex inSection:0];
		[self.collectionView layoutIfNeeded];
		return [self.collectionView cellForItemAtIndexPath:indexPath] ?: [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
	}
	return nil;
}

#pragma mark - Internal

- (NSArray *)evaluateTabTitles {
	NSArray *tabTitles = [[self.dataSource tabTitlesForTabBarView:self] copy];
	return tabTitles;
}

- (NSInteger)evaluateDataSource {
	NSInteger tabCount = 0;
	if ([self.dataSource respondsToSelector:@selector(numberOfItemsForTabBarView:)]) {
		tabCount = [self.dataSource numberOfItemsForTabBarView:self];
	}
	else if ([self.dataSource respondsToSelector:@selector(tabTitlesForTabBarView:)]) {
		
		self.tabTitles = [self evaluateTabTitles];
		tabCount = self.tabTitles.count;
	}
	_tabCount = tabCount;
	return tabCount;
}

- (NSString *)titleAtIndex:(NSInteger)index {
	if (self.tabTitles) {
		return self.tabTitles[index];
	}
	else {
		return [NSString stringWithFormat:MSSTabBarViewDefaultTabTitleFormat, (long) (index + 1)];
	}
}

- (void)reset {
	_selectedCell = nil;
	_selectedIndexPath = nil;
	_hasRespectedDefaultTabIndex = NO;
	_tabOffset = MSSTabBarViewTabOffsetInvalid;
	_previousTabOffset = MSSTabBarViewTabOffsetInvalid;
}

- (void)doSetDataSource:(id <MSSTabBarViewDataSource>)dataSource {
	_dataSource = dataSource;
	[self reset];
	if ([dataSource respondsToSelector:@selector(defaultTabIndexForTabBarView:)]) {
		self.defaultTabIndex = [dataSource defaultTabIndexForTabBarView:self];
	}
	[self.collectionView reloadData];
	[self setNeedsLayout];
}

- (void)updateDistributedCellsCount {
	if (self.axis == UILayoutConstraintAxisHorizontal) {
		CGFloat containerWidth = CGRectGetWidth(self.bounds);
		CGFloat cellsWidth = self.collectionView.contentInset.left;
		NSUInteger index = 0;
		while (index < [self collectionView:self.collectionView numberOfItemsInSection:0]) {
			cellsWidth += [self getSizeToFitCellSize:self.collectionView forIndex:index].width;
			UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
			cellsWidth += layout.minimumInteritemSpacing;
			if (containerWidth <= cellsWidth) {
				break;
			}
			index++;
		}
		self.maxDistributedTabs = index;
	}
}

- (CGSize)getSizeToFitCellSize:(UICollectionView *)collectionView forIndex:(NSUInteger)index {
	if ([self.dataSource respondsToSelector:@selector(tabBarView:populateTab:atIndex:)]) {
		[self.dataSource tabBarView:self populateTab:self.sizingCell atIndex:index];
	}
	else {
		self.sizingCell.title = [self titleAtIndex:index];
	}
	
	[self.sizingCell setNeedsLayout];
	[self.sizingCell layoutIfNeeded];
	
	CGSize fittingSize = UILayoutFittingCompressedSize;
	fittingSize.height = CGRectGetHeight(collectionView.bounds);
	
	CGSize requiredSize = [self.sizingCell systemLayoutSizeFittingSize:fittingSize
										   withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel
										   verticalFittingPriority:UILayoutPriorityRequired];
	requiredSize.width += self.tabPadding;
	return requiredSize;
}

- (void)updateCellAppearance:(MSSTabBarCollectionViewCell *)cell {
	
	// default appearance
	if (self.tabAttributes) {
		UIColor *tabTextColor;
		if ((tabTextColor = self.tabAttributes[MSSTabTextColor]) || (tabTextColor = self.tabAttributes[NSForegroundColorAttributeName])) {
			
			cell.textColor = tabTextColor;
		}
		
		UIFont *tabTextFont;
		if ((tabTextFont = self.tabAttributes[MSSTabTextFont]) || (tabTextFont = self.tabAttributes[NSFontAttributeName])) {
			cell.textFont = tabTextFont;
		}
		
		UIColor *tabBackgroundColor;
		if ((tabBackgroundColor = self.tabAttributes[NSBackgroundColorAttributeName])) {
			cell.tabBackgroundColor = tabBackgroundColor;
		}
		
		NSNumber *alphaEffectEnabled;
		if ((alphaEffectEnabled = self.tabAttributes[MSSTabTransitionAlphaEffectEnabled])) {
			cell.alphaEffectEnabled = [alphaEffectEnabled boolValue];
		}
		
		NSNumber *deselectedAlphaValue;
		if ((deselectedAlphaValue = self.tabAttributes[MSSTabTitleAlpha])) {
			self.tabDeselectedAlpha = [deselectedAlphaValue floatValue];
		}
	}
	else {
		cell.textColor = self.tabTextColor;
		if (self.tabTextFont) {
			cell.textFont = self.tabTextFont;
		}
	}
	
	// selected appearance
	if (self.selectedTabAttributes) {
		UIColor *selectedTabTextColor;
		if ((selectedTabTextColor = self.selectedTabAttributes[MSSTabTextColor]) ||
			(selectedTabTextColor = self.selectedTabAttributes[NSForegroundColorAttributeName])) {
			
			cell.selectedTextColor = selectedTabTextColor;
		}
		
		UIFont *selectedTabTextFont;
		if ((selectedTabTextFont = self.selectedTabAttributes[MSSTabTextFont]) || (selectedTabTextFont = self.selectedTabAttributes[NSFontAttributeName])) {
			
			cell.selectedTextFont = selectedTabTextFont;
		}
		
		UIColor *selectedTabBackgroundColor;
		if ((selectedTabBackgroundColor = self.selectedTabAttributes[NSBackgroundColorAttributeName])) {
			cell.selectedTabBackgroundColor = selectedTabBackgroundColor;
		}
	}
	
	cell.backgroundColor = [UIColor clearColor];
	[cell setContentBottomMargin:[self.indicatorAttributes[MSSTabIndicatorLineHeight] floatValue]];
}

- (void)updateIndicatorForStyle:(MSSIndicatorStyle)indicatorStyle {
	[self.indicatorContainer mss_clearSubviews];
	
	UIView *indicatorView;
	switch (indicatorStyle) {
		case MSSIndicatorStyleLine: {
			UIView *indicatorLineView = [UIView new];
			[self.indicatorContainer addSubview:indicatorLineView];
			
			indicatorView = indicatorLineView;
		}
			break;
		
		case MSSIndicatorStyleImage: {
			UIImageView *imageView = [UIImageView new];
			imageView.contentMode = UIViewContentModeBottom;
			[self.indicatorContainer addSubview:imageView];
			
			indicatorView = imageView;
		}
			break;
		
		default:
			break;
	}
	
	self.indicatorView = indicatorView;
	[self updateIndicatorAppearance];
}

- (void)updateIndicatorAppearance {
	if (self.indicatorAttributes) {
		
		switch (self.indicatorStyle) {
			case MSSIndicatorStyleLine: {
				
				UIColor *indicatorColor;
				if ((indicatorColor = self.indicatorAttributes[NSForegroundColorAttributeName])) {
					self.indicatorView.backgroundColor = indicatorColor;
				}
				
				NSNumber *indicatorHeight;
				if ((indicatorHeight = self.indicatorAttributes[MSSTabIndicatorLineHeight])) {
					self.lineIndicatorHeight = [indicatorHeight floatValue];
				}
			}
				break;
			
			case MSSIndicatorStyleImage: {
				UIImageView *indicatorImageView = (UIImageView *) self.indicatorView;
				
				UIColor *indicatorTintColor;
				if ((indicatorTintColor = self.indicatorAttributes[MSSTabIndicatorImageTintColor])) {
					indicatorImageView.tintColor = indicatorTintColor;
				}
				
				UIImage *indicatorImage;
				if ((indicatorImage = self.indicatorAttributes[MSSTabIndicatorImage])) {
					indicatorImageView.image = [indicatorImage imageWithRenderingMode:indicatorTintColor ? UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAlwaysOriginal];
				}
			}
				break;
		}
	}
}

- (void)updateIndicatorFrames {
	CGRect containerBounds = self.indicatorContainer.bounds;
	
	CGFloat height = 0.0f;
	switch (self.indicatorStyle) {
		case MSSIndicatorStyleLine:
			height = self.lineIndicatorHeight;
			break;
		
		case MSSIndicatorStyleImage:
			height = self.indicatorContainer.bounds.size.height;
			break;
	}
	
	self.indicatorView.frame = CGRectMake(0.0f, containerBounds.size.height - height, containerBounds.size.width, height);
}

- (CGFloat)tabDeselectedAlpha {
	if (_tabDeselectedAlpha == 0.0f) {
		return MSSTabBarViewDefaultTabUnselectedAlpha;
	}
	else {
		return _tabDeselectedAlpha;
	}
}

#pragma clang diagnostic pop

@end
