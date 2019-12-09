export ARCHS = arm64 arm64e
DEBUG = 0
export TARGET = iphone:clang:12.1

PACKAGE_VERSION = 13.1

export SYSROOT = $(THEOS)/sdks/iPhoneOS12.1.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CustomFolderIcons
CustomFolderIcons_FILES = Tweak.xm
CustomFolderIcons_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += customfoldericons
include $(THEOS_MAKE_PATH)/aggregate.mk
