SUMMARY = "Display IBM 2030 local storage (/dev/axi2)"
DESCRIPTION = "ls_dump formats the IBM System/360 Model 30 local storage, read through \
the axibram driver: general and floating point registers, PSW fields, selector and \
multiplexor channel state, and the multiplexor UCWs. Source: utils/ls_dump.c in the \
IBM2030 repository (keep files/ls_dump.c in step with it)."
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://ls_dump.c"

S = "${WORKDIR}"

RDEPENDS:${PN} += "axibram"

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} -Wall -o ls_dump ls_dump.c
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ls_dump ${D}${bindir}/ls_dump
}
