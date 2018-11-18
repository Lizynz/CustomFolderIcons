export ARCHS = arm64
DEBUG = 0
export TARGET = iphone:clang:9.3

PACKAGE_VERSION = 11.0-1

export SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CustomFolderIcons
CustomFolderIcons_FILES = Tweak.xm
CustomFolderIcons_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += customfoldericons
include $(THEOS_MAKE_PATH)/aggregate.mk
