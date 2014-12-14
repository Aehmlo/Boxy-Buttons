#import <objc/runtime.h>

#define IS_PHONE_APP [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilephone"]

@interface TPSuperBottomBarButton : UIView //Eventually

+ (UIFont *)defaultFont;
- (void)setSelected:(BOOL)arg1;
- (void)setHighlighted:(BOOL)arg1;
- (void)setUsesSmallerFontSize:(BOOL)arg1;

@end

static SEL dimmingViewKey = @selector(albb_dimmingView);

%hook TPSuperBottomBarButton

- (id)initWithTitle:(id)arg1 icon:(id)arg2 color:(id)arg3 {
	self = %orig(arg1, nil, arg3);
	[self setTranslatesAutoresizingMaskIntoConstraints:NO];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.font = [UIFont fontWithName:@"HelveticaNeue" size:24];//[[self class] defaultFont];
	label.textColor = [UIColor whiteColor];
	label.text = ([arg1 isEqualToString:@"Accept"] && IS_PHONE_APP) ? @"Call" : arg1;
	[label sizeToFit];
	[self addSubview:label];
	[label setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addConstraints:@[
		[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]
	]];
	[label release];

	UIView *dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
	dimmingView.layer.cornerRadius = 7;
	dimmingView.backgroundColor = [UIColor blackColor];
	dimmingView.alpha = 0;
	[self addSubview:dimmingView];
	[dimmingView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addConstraints:@[
		[NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]
	]];
	objc_setAssociatedObject(self, dimmingViewKey, dimmingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[dimmingView release];

	self.layer.cornerRadius = 7;
	self.clipsToBounds = YES;

	return self;
}

- (void)addConstraint:(NSLayoutConstraint *)constraint {
	if(constraint.firstAttribute == NSLayoutAttributeWidth) constraint.constant = IS_PHONE_APP ? 270 : 124;
	if(constraint.firstAttribute == NSLayoutAttributeHeight) constraint.constant = 0.85 * constraint.constant;
	%orig(constraint);
}

- (void)setHighlighted:(BOOL)arg1 {
	UIView *dim = objc_getAssociatedObject(self, dimmingViewKey);
	dim.alpha = arg1 ? 0.3 : 0;
}

%end