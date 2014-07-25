TARGET := iphone:7.0:2.0
ARCHS := armv6 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CustomFolderIcons
CustomFolderIcons_FILES = Tweak.xm
CustomFolderIcons_FRAMEWORKS = UIKit

BUNDLE_NAME = CustomFolderIconsSettings
CustomFolderIconsSettings_FILES = Preferences.m
CustomFolderIconsSettings_INSTALL_PATH = /Library/PreferenceBundles
CustomFolderIconsSettings_FRAMEWORKS = UIKit
CustomFolderIconsSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomFolderIcons.plist$(ECHO_END)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
