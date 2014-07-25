#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

__attribute__((visibility("hidden")))
@interface CFIListController : PSListController
- (id)specifiers;
@end

@implementation CFIListController

- (id)specifiers
{
	if(_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CustomFolderIcons" target:self] retain];

	return _specifiers;
}

- (void)launchTwitter:(id)specifier
{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/magn2o"]];
	else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/magn2o/"]];
}

@end
