export ARCHS = arm64
DEBUG = 0
export TARGET = iphone:clang:11.2

PACKAGE_VERSION = 12.0

export SYSROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CustomFolderIcons
CustomFolderIcons_FILES = Tweak.xm
CustomFolderIcons_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += customfoldericons
include $(THEOS_MAKE_PATH)/aggregate.mk
