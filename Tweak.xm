static BOOL enabled;

@interface SBIconView : UIView
+ (CGSize)defaultIconImageSize;
@end

@interface SBFolderIconView : UIView
- (UIView *)backgroundView;
@end

@interface SBFolderBackgroundView : UIView
+ (CGSize)folderBackgroundSize;
+ (double)cornerRadiusToInsetContent;
@end

UIImageView* _backgroundImageView;
UIImageView* _folderIcon;

%hook SBFolderIconImageView

- (UIView *)backgroundView {
      
      if(enabled) {
      
      UIView * view = %orig;
      
      UIImageView *folderIcon = MSHookIvar<UIImageView *>(self, "_folderIcon");
      folderIcon = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/CustomFolderIcons/FolderImage.png"]];
      
      CGRect newFrame = folderIcon.frame;
      newFrame.size = CGSizeMake(60, 60);
      folderIcon.frame = newFrame;
      
      [view addSubview:folderIcon];
      
      return view;
      }
   return %orig;
}

%end

%hook SBFolderBackgroundView

- (id)initWithFrame:(CGRect)arg1 {
      
      if(enabled) {
      
      id view = %orig;
      
      UIImageView *backgroundImageView = MSHookIvar<UIImageView *>(self, "_backgroundImageView");
      backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/CustomFolderIcons/FolderImage.png"]];
      
      CGRect newFrame = backgroundImageView.frame;
      newFrame.size = CGSizeMake(305, 330);
      backgroundImageView.frame = newFrame;
      
      self.layer.masksToBounds = YES;
      self.layer.cornerRadius = [%c(SBFolderBackgroundView) cornerRadiusToInsetContent];
      
      [view addSubview:backgroundImageView];
      
      return view;
      }
   return %orig;
}

%end

static void loadSettings() {
NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.fortysixandtwo.customfoldericons.plist"] autorelease];

if([settings objectForKey:@"enabled"]) enabled = [[settings objectForKey:@"enabled"] boolValue];
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
