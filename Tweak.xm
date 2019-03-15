static BOOL enabled;
static BOOL shouldHideMiniGrid = NO;

@interface _UILegibilityView : UIView @end

@interface SBFolderIconBackgroundView : UIView @end

@interface SBIconView : UIView
+ (struct CGSize)defaultIconImageSize;
@end
@interface SBFolderIconView : SBIconView
- (id)_folderIconImageView;
@end
@interface SBIconImageView : UIView
+ (double)cornerRadius;
@end

@interface SBFolderBackgroundView : UIView
+ (CGSize)folderBackgroundSize;
+ (double)cornerRadiusToInsetContent;
@end

UIImageView* _backgroundImageView;
UIImageView* _folderIcon;

%hook SBIcon

- (id)gridCellImage
{
return enabled && shouldHideMiniGrid ? nil : %orig;
}

%end

%hook SBFolderIconView

- (void)setIcon:(SBIcon *)icon {
%orig;

if(enabled) {

UIImageView *folderIcon = MSHookIvar<UIImageView *>(self, "_folderIcon");
folderIcon = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/CustomFolderIcons/FolderImage.png"]];

CGRect newFrame = folderIcon.frame;
newFrame.size = [%c(SBIconView) defaultIconImageSize];
folderIcon.frame = newFrame;

folderIcon.layer.masksToBounds = YES;
folderIcon.layer.cornerRadius = [%c(SBIconImageView) cornerRadius];

[self insertSubview:folderIcon atIndex:1];

}}

%end

%hook SBFolderIconBackgroundView
-(void)setWallpaperBackgroundRect:(CGRect)arg1 forContents:(CGImageRef)arg2 withFallbackColor:(CGColorRef)arg3 {
if (enabled) {
      }else{
return %orig;
}}
%end

%hook SBFolderBackgroundView

- (id)initWithFrame:(CGRect)arg1 {
if(enabled) {

id view = %orig;

UIImageView *backgroundImageView = MSHookIvar<UIImageView *>(self, "_backgroundImageView");
backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/CustomFolderIcons/FolderImage.png"]];

CGRect newFrame = backgroundImageView.frame;
newFrame.size = [%c(SBFolderBackgroundView) folderBackgroundSize];
backgroundImageView.frame = newFrame;

_backgroundImageView.layer.masksToBounds = YES;
_backgroundImageView.layer.cornerRadius = [%c(SBFolderBackgroundView) cornerRadiusToInsetContent];

[view addSubview:backgroundImageView];

return view;
}
return %orig;
}

- (void)layoutSubviews {
if (enabled) {
_backgroundImageView.hidden = NO;
}else{
return %orig;
}}

%end

static void loadSettings() {
NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.fortysixandtwo.customfoldericons.plist"] autorelease];

if([settings objectForKey:@"enabled"]) enabled = [[settings objectForKey:@"enabled"] boolValue];
if([settings objectForKey:@"shouldHideMiniGrid"]) shouldHideMiniGrid = [[settings objectForKey:@"shouldHideMiniGrid"] boolValue];
}

static void reloadPrefsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
loadSettings();
}

%ctor {
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
%init;

CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&reloadPrefsNotification, CFSTR("com.fortysixandtwo.customfoldericons/settingschanged"), NULL, 0);

loadSettings();
[pool drain];
}
