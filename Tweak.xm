#import "IconOmatic.h"

// Borrowed from Alex Zielenski <3
#define IS_RETINA() ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define RETINIZE(r) [(IS_RETINA()) ? [r stringByAppendingString:@"@2x"] : r stringByAppendingPathExtension: @"png"]

static BOOL shouldUseIconMasks = YES;
static BOOL shouldHideIconLabels = NO;
static BOOL shouldHideFolderIconLabels = NO;
static BOOL shouldHideFolderBadges = NO;
static BOOL shouldHideMiniGrid = YES;

static BOOL isUsingIconomatic = NO;

@interface _UILegibilityView : UIView
@end

@interface SBIcon : NSObject
- (id)displayName;
@end

@interface SBIconView : UIView
+ (struct CGSize)defaultIconImageSize;
- (void)setLabelHidden:(BOOL)hidden;
@end

@interface SBFolderIconView : SBIconView
- (id)iconBackgroundView;
- (id)_folderIconImageView;
@end

@interface SBFolderIconView (CustomFolderIcons)
- (UIImageView *)customImageView;
- (void)setCustomImageView:(UIImageView *)imageView;
- (void)setCustomIconImage:(UIImage *)image;
@end

@interface UIImage (UIApplicationIconPrivate)
- (id)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed;
@end

%hook SBIconView
- (void)layoutSubviews
{
    %orig;
    MSHookIvar<_UILegibilityView *>(self, "_labelView").hidden = shouldHideIconLabels ? YES : NO;
}
%end

%hook SBFolderIcon
- (id)miniGridCellImageForIcon:(id)icon
{
    return shouldHideMiniGrid ? [[[UIImage alloc] init] autorelease] : %orig;
}

- (void)setBadge:(id)badge
{
    shouldHideFolderBadges ? %orig(nil) : %orig;
}
%end

%hook SBFolderIconView
static UIImageView *customImageView;

- (void)layoutSubviews
{
    %orig;
    MSHookIvar<UIView *>(self, "_labelView").hidden = shouldHideFolderIconLabels ? YES : NO;
}

- (void)setIcon:(SBIcon *)icon
{
    %orig;
    NSString *customImagePath = [NSString stringWithFormat:@"/private/var/mobile/Library/CustomFolderIcons/%@", RETINIZE([icon displayName])];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:customImagePath])
    {
        [self setCustomIconImage:[[UIImage alloc] initWithContentsOfFile:customImagePath]];
        
        MSHookIvar<UIView *>([self _folderIconImageView], "_backgroundView").hidden = YES;
        
        if(shouldHideMiniGrid)
        {
            MSHookIvar<UIView *>([self _folderIconImageView], "_pageGridContainer").hidden = YES;
        }
    }
}

- (void)dealloc
{
    [self.customImageView release];
    %orig;
}

- (id)initWithFrame:(struct CGRect)frame
{
    UIView *view = %orig;
    
    CGSize size = [%c(SBIconView) defaultIconImageSize];
    self.customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, size.width, size.height)];
    self.customImageView.backgroundColor = [UIColor clearColor];
    
    [view insertSubview:self.customImageView atIndex:1];
    
    return view;
}

%new(@@:)
- (UIImageView *)customImageView
{
    return objc_getAssociatedObject(self, &customImageView);
}

%new(v@:@)
- (void)setCustomImageView:(UIImageView *)imageView
{
    objc_setAssociatedObject(self, &customImageView, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(v@:@)
- (void)setCustomIconImage:(UIImage *)image
{
    UIImage *_image = shouldUseIconMasks ? [image _applicationIconImageForFormat:2 precomposed:NO] : image;

    if(isUsingIconomatic && [%c(IconOmatic) respondsToSelector:@selector(redrawIconWithOverlay:)])
    {
        _image = [%c(IconOmatic) redrawIconWithOverlay:_image];
    }
    
    self.customImageView.image = _image;
}
%end

static void loadSettings()
{
    NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.fortysixandtwo.customfoldericons.plist"] autorelease];

    if([settings objectForKey:@"shouldUseIconMasks"]) shouldUseIconMasks = [[settings objectForKey:@"shouldUseIconMasks"] boolValue];
    if([settings objectForKey:@"shouldHideIconLabels"]) shouldHideIconLabels = [[settings objectForKey:@"shouldHideIconLabels"] boolValue];
    if([settings objectForKey:@"shouldHideFolderIconLabels"]) shouldHideFolderIconLabels = [[settings objectForKey:@"shouldHideFolderIconLabels"] boolValue];
    if([settings objectForKey:@"shouldHideFolderBadges"]) shouldHideFolderBadges = [[settings objectForKey:@"shouldHideFolderBadges"] boolValue];
    if([settings objectForKey:@"shouldHideMiniGrid"]) shouldHideMiniGrid = [[settings objectForKey:@"shouldHideMiniGrid"] boolValue];
}

static void reloadPrefsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    loadSettings();
}

%ctor
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&reloadPrefsNotification, CFSTR("com.fortysixandtwo.customfoldericons/settingschanged"), NULL, 0);
    
    if(dlopen("/Library/MobileSubstrate/DynamicLibraries/IconOmatic.dylib", RTLD_NOW) != NULL)
    {
        isUsingIconomatic = YES;
    }
    
    loadSettings();
    [pool drain];
}