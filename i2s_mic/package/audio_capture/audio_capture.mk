################################################################################
# audio_capture Buildroot package
################################################################################

# Package details
AUDIO_CAPTURE__VERSION = custom
AUDIO_CAPTURE__SOURCE = i2s.tar.gz
AUDIO_CAPTURE__SITE = 0.0.0.0:8000

# Target binary name
AUDIO_CAPTURE_BIN = audio_capture

# Specify dependencies
AUDIO_CAPTURE_DEPENDENCIES = alsa-lib

# Build and install steps
define AUDIO_CAPTURE_BUILD_CMDS
    $(TARGET_CC) -o $(@D)/$(AUDIO_CAPTURE_BIN) \
        $(@D)/audio_capture.c -lasound
endef

define AUDIO_CAPTURE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/$(AUDIO_CAPTURE_BIN) \
        $(TARGET_DIR)/home/pi/$(AUDIO_CAPTURE_BIN)
endef

# Register package with Buildroot
$(eval $(generic-package))
