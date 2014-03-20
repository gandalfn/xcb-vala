vapidir = $(pkgdatadir)/vapi

%.deps: %.vapi

xcb.vapi: @XCB_XML_PATH@/xproto.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-bigreq.vapi: @XCB_XML_PATH@/bigreq.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-composite.vapi: @XCB_XML_PATH@/composite.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-damage.vapi: @XCB_XML_PATH@/damage.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-dpms.vapi: @XCB_XML_PATH@/dpms.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-dri2.vapi: @XCB_XML_PATH@/dri2.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

if XCB_1_10
xcb-dri3.vapi: @XCB_XML_PATH@/dri3.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-present.vapi: @XCB_XML_PATH@/present.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@
endif 

xcb-ge.vapi: @XCB_XML_PATH@/ge.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-glx.vapi: @XCB_XML_PATH@/glx.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-randr.vapi: @XCB_XML_PATH@/randr.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-record.vapi: @XCB_XML_PATH@/record.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-render.vapi: @XCB_XML_PATH@/render.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-res.vapi: @XCB_XML_PATH@/res.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-screensaver.vapi: @XCB_XML_PATH@/screensaver.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-shape.vapi: @XCB_XML_PATH@/shape.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-shm.vapi: @XCB_XML_PATH@/shm.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-sync.vapi: @XCB_XML_PATH@/sync.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xc_misc.vapi: @XCB_XML_PATH@/xc_misc.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xevie.vapi: @XCB_XML_PATH@/xevie.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xf86dri.vapi: @XCB_XML_PATH@/xf86dri.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xf86vidmode.vapi: @XCB_XML_PATH@/xf86vidmode.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xfixes.vapi: @XCB_XML_PATH@/xfixes.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xinerama.vapi: @XCB_XML_PATH@/xinerama.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xinput.vapi: @XCB_XML_PATH@/xinput.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xkb.vapi: @XCB_XML_PATH@/xkb.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xprint.vapi: @XCB_XML_PATH@/xprint.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xselinux.vapi: @XCB_XML_PATH@/xselinux.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xtest.vapi: @XCB_XML_PATH@/xtest.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xvmc.vapi: @XCB_XML_PATH@/xvmc.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

xcb-xv.vapi: @XCB_XML_PATH@/xv.xml
	$(AM_V_GEN)${top_builddir}/src/xcb-vapigen $< $@

vapi_DATA = \
	gl.vapi \
	glx.vapi \
	glu.vapi \
	xcb-base.vapi \
	xcb.vapi \
	xcb-bigreq.vapi \
	xcb-composite.vapi \
	xcb-damage.vapi \
	xcb-dpms.vapi \
	xcb-dri2.vapi \
	xcb-ge.vapi \
	xcb-glx.vapi \
	xcb-randr.vapi \
	xcb-record.vapi \
	xcb-randr.vapi \
	xcb-render.vapi \
	xcb-res.vapi \
	xcb-screensaver.vapi \
	xcb-shape.vapi \
	xcb-shm.vapi \
	xcb-sync.vapi \
	xcb-xc_misc.vapi \
	xcb-xevie.vapi \
	xcb-xf86dri.vapi \
	xcb-xf86vidmode.vapi \
	xcb-xfixes.vapi \
	xcb-xinerama.vapi \
	xcb-xinput.vapi \
	xcb-xkb.vapi \
	xcb-xprint.vapi \
	xcb-xselinux.vapi \
	xcb-xtest.vapi \
	xcb-xvmc.vapi \
	xcb-xv.vapi \
	xcb-base.deps \
	xcb.deps \
	xcb-bigreq.deps \
	xcb-composite.deps \
	xcb-damage.deps \
	xcb-dpms.deps \
	xcb-dri2.deps \
	xcb-ge.deps \
	xcb-glx.deps \
	xcb-randr.deps \
	xcb-record.deps \
	xcb-randr.deps \
	xcb-render.deps \
	xcb-res.deps \
	xcb-screensaver.deps \
	xcb-shape.deps \
	xcb-shm.deps \
	xcb-sync.deps \
	xcb-xc_misc.deps \
	xcb-xevie.deps \
	xcb-xf86dri.deps \
	xcb-xfixes.deps \
	xcb-xinerama.deps \
	xcb-xinput.deps \
	xcb-xprint.deps \
	xcb-xselinux.deps \
	xcb-xtest.deps \
	xcb-xv.deps \
	xcb-xvmc.deps \
	xcb-xf86vidmode.deps \
	xcb-xkb.deps

if XCB_1_10
vapi_DATA +=
	xcb-dri3.vapi \
	xcb-present.vapi \
	xcb-dri3.deps \
	xcb-present.deps
endif

CLEANFILES = \
	xcb.vapi \
	xcb-bigreq.vapi \
	xcb-composite.vapi \
	xcb-damage.vapi \
	xcb-dpms.vapi \
	xcb-dri2.vapi \
	xcb-dri3.vapi \
	xcb-present.vapi \
	xcb-ge.vapi \
	xcb-glx.vapi \
	xcb-randr.vapi \
	xcb-record.vapi \
	xcb-randr.vapi \
	xcb-render.vapi \
	xcb-res.vapi \
	xcb-screensaver.vapi \
	xcb-shape.vapi \
	xcb-shm.vapi \
	xcb-sync.vapi \
	xcb-xc_misc.vapi \
	xcb-xevie.vapi \
	xcb-xf86dri.vapi \
	xcb-xf86vidmode.vapi \
	xcb-xfixes.vapi \
	xcb-xinerama.vapi \
	xcb-xinput.vapi \
	xcb-xkb.vapi \
	xcb-xprint.vapi \
	xcb-xselinux.vapi \
	xcb-xtest.vapi \
	xcb-xvmc.vapi \
	xcb-xv.vapi \
	xcb.deps \
	xcb-bigreq.deps \
	xcb-composite.deps \
	xcb-damage.deps \
	xcb-dpms.deps \
	xcb-dri2.deps \
	xcb-dri3.deps \
	xcb-present.deps \
	xcb-ge.deps \
	xcb-glx.deps \
	xcb-randr.deps \
	xcb-record.deps \
	xcb-randr.deps \
	xcb-render.deps \
	xcb-res.deps \
	xcb-screensaver.deps \
	xcb-shape.deps \
	xcb-shm.deps \
	xcb-sync.deps \
	xcb-xc_misc.deps \
	xcb-xevie.deps \
	xcb-xf86dri.deps \
	xcb-xf86vidmode.deps \
	xcb-xfixes.deps \
	xcb-xinerama.deps \
	xcb-xinput.deps \
	xcb-xkb.deps \
	xcb-xprint.deps \
	xcb-xselinux.deps \
	xcb-xtest.deps \
	xcb-xvmc.deps \
	xcb-xv.deps

.NOTPARALLEL: %.deps
