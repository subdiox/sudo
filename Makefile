include $(THEOS)/makefiles/common.mk

TOOL_NAME = sudo
sudo_FILES = main.mm
sudo_CODESIGN_FLAGS = -Sent.plist

include $(THEOS_MAKE_PATH)/tool.mk
