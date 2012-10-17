obj-m := test.o
#KDIR := /home/xzl/android-galaxys2/siyah-kernel-ICS/siyahkernel3
KDIR := /home/xzl/pandroid.gingerbread/L27.12.1-P2/kernel/android-2.6.35
PWD := $(shell pwd)

.PHONY: all clean

all:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
clean:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) clean
