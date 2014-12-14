export TARGET=iphone:clang:latest:8.0
export ARCHS=armv7 arm64
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

include theos/makefiles/common.mk

TWEAK_NAME = BoxyButtons
BoxyButtons_FILES = Tweak.xm
BoxyButtons_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
