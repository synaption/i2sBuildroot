MOD_NAME	:= snd-i2smic-rpi

# call from kernel build system

obj-m := $(MOD_NAME).o

# external module build

EXTRA_FLAGS += -I$(PWD)

#
# KDIR is a path to a directory containing kernel source.
# It can be specified on the command line passed to make to enable the module to
# be built and installed for a kernel other than the one currently running.
# By default it is the path to the symbolic link created when
# the current kernel's modules were installed, but
# any valid path to the directory in which the target kernel's source is located
# can be provided on the command line.
#
KDIR	?= /home/bob/i2sBuildroot/output_coral/build/linux-lf-6.1.36-2.1.0/
MDIR	?= /home/bob/i2sBuildroot/output_coral/build/snd_i2s_rpi-custom
PWD	:= $(shell pwd)

export CONFIG_SND_I2S_RPI := m

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

help:
	$(MAKE) -C $(KDIR) M=$(PWD) help

install: snd-i2smic-rpi.ko
	rm -f $(MDIR)/$(MOD_NAME).ko
	install -m644 -b -D $(MOD_NAME).ko $(MDIR)/$(MOD_NAME).ko
	depmod -a

modules:
	@$(MAKE) -C $(KDIR) M=$$PWD modules

modules_install: 
	@$(MAKE) -C $(KDIR) M=$$PWD modules_install

uninstall:
	rm -rf $(MDIR)/$(MOD_NAME).ko
	depmod -a


.PHONY : all clean install uninstall
