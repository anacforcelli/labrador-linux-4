
CURDIR=$(shell pwd)
CPUS=$$(($(shell cat /sys/devices/system/cpu/present | awk -F- '{ print $$2 }')+1))
KERNEL=$(CURDIR)/linux-source-4.19
BUILDK7=$(CURDIR)/build-k7
OUTPUTK7=$(CURDIR)/output-k7
COMPILERK7=aarch64-linux-gnu-

BUILDK5=$(CURDIR)/build-k5
OUTPUTK5=$(CURDIR)/output-k5
COMPILERK5=arm-linux-gnueabihf-

.PHONY: all config-k7 menuconfig-k7 dtbs-k7 kernel-k7 clean-k7 config-k5 menuconfig-k5 dtbs-k5 kernel-k5 clean-k5 

all: clean-k5 config-k5 kernel-k5 clean-k7 config-k7 dtbs-k7 kernel-k7

k5: clean-k5 config-k5 kernel-k5

k7: clean-k7 config-k7 dtbs-k7 kernel-k7

config-k5:
	$(Q)mkdir $(BUILDK5)
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm caninosk5_defconfig
	
menuconfig-k5:
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm menuconfig
	
dtbs-k5:
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm dtbs
	$(Q)mkdir -p $(OUTPUTK5)
	$(Q)cp $(BUILD32)/arch/arm/boot/dts/caninosk5_labrador.dtb $(OUTPUTK5)/kernel.dtb

kernel-k5: 
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm -j$(CPUS) dtbs
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm -j$(CPUS) uImage modules
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK5) CROSS_COMPILE=$(COMPILERK5) ARCH=arm -j$(CPUS) INSTALL_MOD_PATH=$(BUILDK5) modules_install
	$(Q)rm -rf $(OUTPUTK5)/lib
	$(Q)mkdir -p $(OUTPUTK5)/lib
	$(Q)cp -rf $(BUILDK5)/lib/modules $(OUTPUTK5)/lib/; find $(OUTPUTK5)/lib/ -type l -exec rm -f {} \;
	$(Q)cp $(BUILDK5)/arch/arm/boot/uImage $(OUTPUTK5)/
	$(Q)cp $(BUILDK5)/arch/arm/boot/dts/caninosk5_labrador.dtb $(OUTPUTK5)/kernel.dtb
	
clean-k5:
	$(Q)rm -rf $(BUILDK5)
	$(Q)rm -rf $(OUTPUTK5)

config-k7:
	$(Q)mkdir $(BUILDK7)
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK7) CROSS_COMPILE=$(COMPILERK7) ARCH=arm64 caninosk7_defconfig
	
menuconfig-k7:
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK7) CROSS_COMPILE=$(COMPILERK7) ARCH=arm64 menuconfig
	
dtbs-k7:
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK7) CROSS_COMPILE=$(COMPILERK7) ARCH=arm64 dtbs
	$(Q)mkdir -p $(OUTPUTK7)
	$(Q)cp $(BUILDK7)/arch/arm64/boot/dts/caninos/v3sdc.dtb $(OUTPUTK7)/
	$(Q)cp $(BUILDK7)/arch/arm64/boot/dts/caninos/v3emmc.dtb $(OUTPUTK7)/
	$(Q)cp $(BUILDK7)/arch/arm64/boot/dts/caninos/v3psci.dtb $(OUTPUTK7)/
	
kernel-k7:
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK7) CROSS_COMPILE=$(COMPILERK7) ARCH=arm64 -j$(CPUS) Image modules
	$(Q)$(MAKE) -C $(KERNEL) O=$(BUILDK7) CROSS_COMPILE=$(COMPILERK7) ARCH=arm64 -j$(CPUS) INSTALL_MOD_PATH=$(BUILDK7) modules_install
	$(Q)rm -rf $(OUTPUTK7)/lib
	$(Q)mkdir -p $(OUTPUTK7)/lib
	$(Q)cp -rf $(BUILDK7)/lib/modules $(OUTPUTK7)/lib/; find $(OUTPUTK7)/lib/ -type l -exec rm -f {} \;
	$(Q)cp $(BUILDK7)/arch/arm64/boot/Image $(OUTPUTK7)/

clean-k7:
	$(Q)rm -rf $(BUILDK7)
	
