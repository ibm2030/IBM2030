SUMMARY = "Recipe for  build an external axibram Linux kernel module"
SECTION = "PETALINUX/modules"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

inherit module

INHIBIT_PACKAGE_STRIP = "1"

SRC_URI = "file://Makefile \
           file://axibram.c \
	   file://COPYING \
          "

S = "${WORKDIR}"

# Load at boot (in addition to modalias autoloading from the DT match)
KERNEL_MODULE_AUTOLOAD += "axibram"

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
