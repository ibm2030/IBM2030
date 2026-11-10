SUMMARY = "Display or patch IBM 2030 main storage (/dev/axi1)"
DESCRIPTION = "ms_dump shows the IBM System/360 Model 30 main storage in hex and EBCDIC, \
read through the axibram driver, and can patch bytes in it. Source: utils/ms_dump.c \
in the IBM2030 repository (keep files/ms_dump.c in step with it)."
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://ms_dump.c"

S = "${WORKDIR}"

RDEPENDS:${PN} += "axibram"

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} -Wall -o ms_dump ms_dump.c
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ms_dump ${D}${bindir}/ms_dump
}
