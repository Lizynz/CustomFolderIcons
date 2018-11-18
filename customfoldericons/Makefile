include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CustomFolderIcons
CustomFolderIcons_FILES = XXXRootListController.m
CustomFolderIcons_INSTALL_PATH = /Library/PreferenceBundles
CustomFolderIcons_FRAMEWORKS = UIKit
CustomFolderIcons_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomFolderIcons.plist$(ECHO_END)
