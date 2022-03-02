KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)
BUILD_DIR_MAKEFILE ?= $(PWD)/Makefile

all: default

default: .config
	$(MAKE) -C $(KERNELDIR) M=$(PWD) src=$(PWD) modules

.config:
	grep config Kconfig | cut -d' ' -f2 | sed 's@^@CONFIG_@; s@$$@=m@' > .config

$(BUILD_DIR):
	mkdir -p "$@"

$(BUILD_DIR_MAKEFILE): $(PWD)
	touch "$@"

install:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) src=$(PWD) modules_install

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) src=$(PWD) clean
