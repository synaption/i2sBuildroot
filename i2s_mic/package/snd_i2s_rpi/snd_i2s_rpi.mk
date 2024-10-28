################################################################################
#
# snd_i2s_rpi
#
################################################################################

SND_I2S_RPI_VERSION = custom
SND_I2S_RPI_SOURCE = i2s.tar.gz
SND_I2S_RPI_SITE = 0.0.0.0:8000
SND_I2S_RPI_LICENSE = GPL-2.0
SND_I2S_RPI_LICENSE_FILES = COPYING


$(eval $(kernel-module))
$(eval $(generic-package))