# -*- mode: makefile -*-

####################################
# Everything below here is generic #
####################################

if GTK_DOC_USE_LIBTOOL
GTKDOC_CC = $(LIBTOOL) --tag=CC --mode=compile $(CC) $(INCLUDES) $(GTKDOC_DEPS_CFLAGS) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
GTKDOC_LD = $(LIBTOOL) --tag=CC --mode=link $(CC) $(GTKDOC_DEPS_LIBS) $(AM_CFLAGS) $(CFLAGS) $(AM_LDFLAGS) $(LDFLAGS)
GTKDOC_RUN = $(LIBTOOL) --mode=execute
else
GTKDOC_CC = $(CC) $(INCLUDES) $(GTKDOC_DEPS_CFLAGS) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
GTKDOC_LD = $(CC) $(GTKDOC_DEPS_LIBS) $(AM_CFLAGS) $(CFLAGS) $(AM_LDFLAGS) $(LDFLAGS)
GTKDOC_RUN =
endif

GTK_DOC_V_SETUP=$(GTK_DOC_V_SETUP_$(V))
GTK_DOC_V_SETUP_=$(GTK_DOC_V_SETUP_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_SETUP_0=@echo "  DOC   Preparing build";

GTK_DOC_V_SCAN=$(GTK_DOC_V_SCAN_$(V))
GTK_DOC_V_SCAN_=$(GTK_DOC_V_SCAN_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_SCAN_0=@echo "  DOC   Scanning header files";

GTK_DOC_V_INTROSPECT=$(GTK_DOC_V_INTROSPECT_$(V))
GTK_DOC_V_INTROSPECT_=$(GTK_DOC_V_INTROSPECT_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_INTROSPECT_0=@echo "  DOC   Introspecting gobjects";

GTK_DOC_V_TMPL=$(GTK_DOC_V_TMPL_$(V))
GTK_DOC_V_TMPL_=$(GTK_DOC_V_TMPL_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_TMPL_0=@echo "  DOC   Rebuilding template files";

GTK_DOC_V_XML=$(GTK_DOC_V_XML_$(V))
GTK_DOC_V_XML_=$(GTK_DOC_V_XML_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_XML_0=@echo "  DOC   Building XML";

GTK_DOC_V_HTML=$(GTK_DOC_V_HTML_$(V))
GTK_DOC_V_HTML_=$(GTK_DOC_V_HTML_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_HTML_0=@echo "  DOC   Building HTML";

GTK_DOC_V_XREF=$(GTK_DOC_V_XREF_$(V))
GTK_DOC_V_XREF_=$(GTK_DOC_V_XREF_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_XREF_0=@echo "  DOC   Fixing cross-references";

GTK_DOC_V_PDF=$(GTK_DOC_V_PDF_$(V))
GTK_DOC_V_PDF_=$(GTK_DOC_V_PDF_$(AM_DEFAULT_VERBOSITY))
GTK_DOC_V_PDF_0=@echo "  DOC   Building PDF";

# To keep compatible with existing usage, this file must
# define EXTRA_DIST and CLEANFILES when included.
EXTRA_DIST =
CLEANFILES =

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
define def-gtk-doc-module-vars
$(eval $(1)TARGET_DIR = $$(HTML_DIR)/$$($(1)DOC_MODULE))

$(eval $(1)SETUP_FILES = \
	$$($(1)content_files) \
	$$($(1)DOC_MAIN_SGML_FILE) \
	$$($(1)DOC_MODULE)-sections.txt \
	$$($(1)DOC_MODULE)-overrides.txt)

$(eval EXTRA_DIST += \
	$$(addprefix $(2), \
		$$($(1)HTML_IMAGES) \
		$$($(1)SETUP_FILES)))

$(eval $(1)DOC_STAMPS = \
	html-build.stamp \
	html.stamp \
	pdf-build.stamp \
	pdf.stamp \
	scan-build.stamp \
	setup-build.stamp \
	sgml-build.stamp \
	sgml.stamp \
	tmpl-build.stamp \
	tmpl.stamp)

$(eval $(1)SCANOBJ_FILES = \
	$$($(1)DOC_MODULE).args \
	$$($(1)DOC_MODULE).hierarchy \
	$$($(1)DOC_MODULE).interfaces \
	$$($(1)DOC_MODULE).prerequisites \
	$$($(1)DOC_MODULE).signals)

$(eval $(1)REPORT_FILES = \
	$$($(1)DOC_MODULE)-undocumented.txt \
	$$($(1)DOC_MODULE)-undeclared.txt \
	$$($(1)DOC_MODULE)-unused.txt)

$(eval CLEANFILES += \
	$$(addprefix $(2), \
		$$($(1)SCANOBJ_FILES) \
		$$($(1)REPORT_FILES) \
		$$($(1)DOC_STAMPS) \
		gtkdoc-check.test))
endef # End of def-gtk-doc-module-vars

.PHONY: all-gtk-doc docs

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
if GTK_DOC_BUILD_HTML
define def-gtk-doc-module-dep-html
all-gtk-doc: $(2)html-build.stamp
docs: $(2)html-build.stamp
endef
else
define def-gtk-doc-module-dep-html
endef
endif

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
if GTK_DOC_BUILD_PDF
define def-gtk-doc-module-dep-pdf
all-gtk-doc: $(2)pdf-build.stamp
docs: $(2)pdf-build.stamp
endef
else
define def-gtk-doc-module-dep-pdf
endef
endif

if ENABLE_GTK_DOC
all-local: all-gtk-doc
endif

.PHONY : dist-hook-local

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
define def-gtk-doc-module-no-cond-rules

#### check ####

$(2)gtkdoc-check.test: Makefile
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	$$(AM_V_GEN)echo "#!/bin/sh -e" > $$@; \
		echo "$$(GTKDOC_CHECK_PATH) || exit 1" >> $$@; \
		chmod +x $$@

#### setup ####

$(2)setup-build.stamp:
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	-$$(GTK_DOC_V_SETUP)if test "$$(abs_srcdir)" != "$$(abs_builddir)" ; then \
	    files=`echo $$(addprefix $(2),$$($(1)SETUP_FILES) $$($(1)expand_content_files) $$($(1)DOC_MODULE).types)`; \
	    if test "x$$$$files" != "x" ; then \
	        for file in $$$$files ; do \
	            destdir=`dirname $$(abs_builddir)/$$$$file` ;\
	            test -d "$$$$destdir" || mkdir -p "$$$$destdir"; \
	            test -f $$(abs_srcdir)/$$$$file && \
	                cp -pf $$(abs_srcdir)/$$$$file $$(abs_builddir)/$$$$file || true; \
	        done; \
	    fi; \
	    test -d $$(abspath $$(srcdir)/$(2)tmpl) && \
	        { cp -pR $$(abspath $$(srcdir)/$(2)tmpl) $$(abspath $$(builddir)/$(2)); \
	        chmod -R u+w $$(abspath $$(builddir)/$(2)tmpl); } \
	fi
	$$(AM_V_at)touch $$@

#### scan ####

$(2)scan-build.stamp: $$(addprefix $(2),setup-build.stamp $$($(1)HFILE_GLOB) $$($(1)CFILE_GLOB))
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	$$(GTK_DOC_V_SCAN)_source_dir='' ; \
	for i in $$($(1)DOC_SOURCE_DIR) ; do \
	    _source_dir="$$$${_source_dir} --source-dir=$$$$i" ; \
	done ; \
	cd $$(@D); gtkdoc-scan --module=$$($(1)DOC_MODULE) --ignore-headers="$$($(1)IGNORE_HFILES)" $$$${_source_dir} $$($(1)SCAN_OPTIONS) $$($(1)EXTRA_HFILES)
	$$(GTK_DOC_V_INTROSPECT)cd $$(@D); if grep -l '^..*$$$$' $$($(1)DOC_MODULE).types > /dev/null 2>&1 ; then \
	    scanobj_options=""; \
	    gtkdoc-scangobj 2>&1 --help | grep  >/dev/null "\-\-verbose"; \
	    if test "$$$$?" = "0"; then \
	        if test "x$$(V)" = "x1"; then \
	            scanobj_options="--verbose"; \
	        fi; \
	    fi; \
	    gtkdoc-scangobj 2>&1 --help | grep  >/dev/null "\-\-output\-dir"; \
	    if test "$$$$?" = "0"; then \
	        scanobj_options="$$$${scanobj_options} --output-dir=$$(@D)"; \
	    fi; \
	    CC="$$(GTKDOC_CC)" LD="$$(GTKDOC_LD)" RUN="$$(GTKDOC_RUN)" CFLAGS="$$($(1)GTKDOC_CFLAGS) $$(CFLAGS)" LDFLAGS="$$($(1)GTKDOC_LIBS) $$(LDFLAGS)" \
	    gtkdoc-scangobj $$($(1)SCANGOBJ_OPTIONS) $$$$scanobj_options --module=$$($(1)DOC_MODULE); \
	else \
	    for i in $$(addprefix $(2),$$($(1)SCANOBJ_FILES)) ; do \
	        test -f $$$$i || ($$(MKDIR_P) $$(dir $$$$i); touch $$$$i) ; \
	    done \
	fi
	$$(AM_V_at)touch $$@

$$(addprefix $(2),$$($(1)DOC_MODULE)-decl.txt $$($(1)SCANOBJ_FILES) $$($(1)DOC_MODULE)-sections.txt $$($(1)DOC_MODULE)-overrides.txt): $(2)scan-build.stamp
	@true

#### templates ####

$(2)tmpl-build.stamp: $$(addprefix $(2),setup-build.stamp $$($(1)DOC_MODULE)-decl.txt $$($(1)SCANOBJ_FILES) $$($(1)DOC_MODULE)-sections.txt $$($(1)DOC_MODULE)-overrides.txt)
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	$$(GTK_DOC_V_TMPL)cd $$(@D); gtkdoc-mktmpl --module=$$($(1)DOC_MODULE) $$($(1)MKTMPL_OPTIONS)
	$$(AM_V_at)if test "$$(abs_srcdir)" != "$$(abs_builddir)" ; then \
	  if test -w $$(abspath $$(srcdir)/$(2)) ; then \
	    cp -pR $$(abspath $$(builddir)/$(2)tmpl) $$(abspath $$(srcdir)/$(2)); \
	  fi \
	fi
	$$(AM_V_at)touch $$@

$(2)tmpl.stamp: $(2)tmpl-build.stamp
	@true

$$(srcdir)/$(2)tmpl/*.sgml:
	@true

#### xml ####

$(2)sgml-build.stamp: $$(addprefix $(2),tmpl.stamp $$($(1)DOC_MODULE)-sections.txt $$($(1)expand_content_files)) $$(srcdir)/$(2)tmpl/*.sgml
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	-$$(GTK_DOC_V_XML)chmod -R u+w $$(@D) && _source_dir='' ; \
	for i in $$($(1)DOC_SOURCE_DIR) ; do \
	    _source_dir="$$$${_source_dir} --source-dir=$$$$i" ; \
	done ; \
	cd $$(@D); gtkdoc-mkdb --module=$$($(1)DOC_MODULE) --output-format=xml --expand-content-files="$$($(1)expand_content_files)" --main-sgml-file=$$($(1)DOC_MAIN_SGML_FILE) $$$${_source_dir} $$($(1)MKDB_OPTIONS)
	$$(AM_V_at)touch $$@

$(2)sgml.stamp: $(2)sgml-build.stamp
	@true

$$(addprefix $(2),$$($(1)REPORT_FILES)): $(2)sgml-build.stamp

#### html ####

$(2)html-build.stamp: $$(addprefix $(2),sgml.stamp $$($(1)DOC_MAIN_SGML_FILE) $$($(1)content_files))
	$$(GTK_DOC_V_HTML)rm -rf $(2)html && mkdir $(2)html && \
	mkhtml_options=""; \
	gtkdoc-mkhtml 2>&1 --help | grep  >/dev/null "\-\-verbose"; \
	if test "$$$$?" = "0"; then \
	  if test "x$$(V)" = "x1"; then \
	    mkhtml_options="$$$$mkhtml_options --verbose"; \
	  fi; \
	fi; \
	gtkdoc-mkhtml 2>&1 --help | grep  >/dev/null "\-\-path"; \
	if test "$$$$?" = "0"; then \
	  mkhtml_options="$$$$mkhtml_options --path=\"$$(abspath $$(srcdir)/$(2))\""; \
	fi; \
	cd $(2)html && gtkdoc-mkhtml $$$$mkhtml_options $$($(1)MKHTML_OPTIONS) $$($(1)DOC_MODULE) ../$$($(1)DOC_MAIN_SGML_FILE)
	-@test "x$$($(1)HTML_IMAGES)" = "x" || \
	for file in $$(addprefix $(2),$$($(1)HTML_IMAGES)) ; do \
	  if test -f $$(abs_srcdir)/$$$$file ; then \
	    cp $$(abs_srcdir)/$$$$file $$(abspath $$(builddir)/$(2)html); \
	  fi; \
	  if test -f $$(abs_builddir)/$$$$file ; then \
	    cp $$(abs_builddir)/$$$$file $$(abspath $$(builddir)/$(2)html); \
	  fi; \
	done;
	$$(GTK_DOC_V_XREF)cd $$(@D); gtkdoc-fixxref --module=$$($(1)DOC_MODULE) --module-dir=html --html-dir=$$(HTML_DIR) $$($(1)FIXXREF_OPTIONS)
	$$(AM_V_at)touch $$@

#### pdf ####

$(2)pdf-build.stamp: $$(addprefix, $(2),sgml.stamp $$($(1)DOC_MAIN_SGML_FILE) $$($(1)content_files))
	$$(AM_V_at)$$(MKDIR_P) $$(@D)
	$(GTK_DOC_V_PDF)rm -f $(2)$$($(1)DOC_MODULE).pdf && \
	mkpdf_options=""; \
	gtkdoc-mkpdf 2>&1 --help | grep  >/dev/null "\-\-verbose"; \
	if test "$$$$?" = "0"; then \
	  if test "x$$(V)" = "x1"; then \
	    mkpdf_options="$$$$mkpdf_options --verbose"; \
	  fi; \
	fi; \
	if test "x$$($(1)HTML_IMAGES)" != "x"; then \
	  for img in $$(addprefix $(2),$$($(1)HTML_IMAGES)); do \
	    part=`dirname $$(abs_srcdir)/$$$$img`; \
	    echo $$$$mkpdf_options | grep >/dev/null "\-\-imgdir=$$$$part "; \
	    if test $$$$? != 0; then \
	      mkpdf_options="$$$$mkpdf_options --imgdir=$$$$part"; \
	    fi; \
	  done; \
	fi; \
	cd $$(@D); gtkdoc-mkpdf --path="$$(abspath $$(srcdir)/$(2))" $$$$mkpdf_options $$($(1)DOC_MODULE) $$($(1)DOC_MAIN_SGML_FILE) $$($(1)MKPDF_OPTIONS)
	$$(AM_V_at)touch $$@

##############

$(1)$$($(1)DOC_MODULE)-clean-local:
	@$(if $(2),cd $(2);) rm -f *~ *.bak; \
	rm -rf .libs; \
	if echo $$($(1)SCAN_OPTIONS) | grep -q "\-\-rebuild-types" ; then \
	  rm -f $$($(1)DOC_MODULE).types; \
	fi

.PHONY: $(1)$$($(1)DOC_MODULE)-clean-local
clean-local: $(1)$$($(1)DOC_MODULE)-clean-local

$(1)$$($(1)DOC_MODULE)-distclean-local:
	@rm -rf $$(addprefix $(2),$$($(1)REPORT_FILES) \
	    xml html $$($(1)DOC_MODULE).pdf $$($(1)DOC_MODULE)-decl-list.txt $$($(1)DOC_MODULE)-decl.txt)
	@if test "$$(abs_srcdir)" != "$$(abs_builddir)" ; then \
	    rm -f $$(addprefix $(2),$$($(1)SETUP_FILES) $$($(1)expand_content_files) $$($(1)DOC_MODULE).types); \
	    rm -rf $(2)tmpl; \
	fi

.PHONY: $(1)$$($(1)DOC_MODULE)-distclean-local
distclean-local: $(1)$$($(1)DOC_MODULE)-distclean-local

$(1)$$($(1)DOC_MODULE)-maintainer-clean-local:
	@rm -rf $(2)xml $(2)html

.PHONY: $(1)$$($(1)DOC_MODULE)-maintainer-clean-local
maintainer-clean-local: $(1)$$($(1)DOC_MODULE)-maintainer-clean-local

$(1)$$($(1)DOC_MODULE)-install-data-local:
	@installfiles=`echo $$(builddir)/$(2)html/*`; \
	if test "$$$$installfiles" = '$(builddir)/$(2)html/*'; \
	then echo 1>&2 'Nothing to install' ; \
	else \
	  if test -n "$$($(1)DOC_MODULE_VERSION)"; then \
	    installdir="$$(DESTDIR)$$($(1)TARGET_DIR)-$$($(1)DOC_MODULE_VERSION)"; \
	  else \
	    installdir="$$(DESTDIR)$$($(1)TARGET_DIR)"; \
	  fi; \
	  $$(mkinstalldirs) $$$${installdir} ; \
	  for i in $$$$installfiles; do \
	    echo ' $$(INSTALL_DATA) '$$$$i ; \
	    $$(INSTALL_DATA) $$$$i $$$${installdir}; \
	  done; \
	  if test -n "$$($(1)DOC_MODULE_VERSION)"; then \
	    mv -f $$$${installdir}/$$($(1)DOC_MODULE).devhelp2 \
	      $$$${installdir}/$$($(1)DOC_MODULE)-$$($(1)DOC_MODULE_VERSION).devhelp2; \
	  fi; \
	  $$(GTKDOC_REBASE) --relative --dest-dir=$$(DESTDIR) --html-dir=$$$${installdir}; \
	fi

.PHONY: $(1)$$($(1)DOC_MODULE)-install-data-local
install-data-local: $(1)$$($(1)DOC_MODULE)-install-data-local

$(1)$$($(1)DOC_MODULE)-uninstall-local:
	@if test -n "$$($(1)DOC_MODULE_VERSION)"; then \
	  installdir="$$(DESTDIR)$$($(1)TARGET_DIR)-$$($(1)DOC_MODULE_VERSION)"; \
	else \
	  installdir="$$(DESTDIR)$$($(1)TARGET_DIR)"; \
	fi; \
	rm -rf $$$${installdir}

.PHONY: $(1)$$($(1)DOC_MODULE)-uninstall-local
uninstall-local: $(1)$$($(1)DOC_MODULE)-uninstall-local

$(1)$$($(1)DOC_MODULE)-dist-hook: dist-check-gtkdoc all-gtk-doc dist-hook-local
	@$$(MKDIR_P) $$(distdir)/$(2)tmpl
	@$$(MKDIR_P) $$(distdir)/$(2)html
	@-cp $(2)tmpl/*.sgml $$(distdir)/$(2)tmpl
	@cp $(2)html/* $$(distdir)/$(2)html
	@-cp $(2)$$($(1)DOC_MODULE).pdf $$(distdir)/$(2)
	@-cp $(2)$$($(1)DOC_MODULE).types $$(distdir)/$(2)
	@-cp $(2)$$($(1)DOC_MODULE)-sections.txt $$(distdir)/$(2)
	@cd $$(distdir) && rm -f $$(DISTCLEANFILES)
	@$$(GTKDOC_REBASE) --online --relative --html-dir=$$(distdir)/$(2)html

.PHONY: $(1)$$($(1)DOC_MODULE)-dist-hook
dist-hook: $(1)$$($(1)DOC_MODULE)-dist-hook

endef # End of def-gtk-doc-module-no-cond-rules

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
define def-gtk-doc-module-rules
$(call def-gtk-doc-module-dep-html,$(1),$(2))
$(call def-gtk-doc-module-dep-pdf,$(1),$(2))
$(call def-gtk-doc-module-no-cond-rules,$(1),$(2))
endef

# $(1): gtk-doc full module name in Makefile.am, e.g. "docs/GtkFoo" or "GtkFoo"
# output: "docs_GtkFoo_" or "".
define am-gtk-doc-full-module-to-prefix
$(if $(filter-out ./,$(dir $(1))),$(shell echo "$(1)" | tr -C "[:alpha:][:digit:]" _))
endef

# $(1): gtk-doc full module name in Makefile.am, e.g. "docs/GtkFoo" or "GtkFoo"
# output: "docs/" or "".
define am-gtk-doc-full-module-to-dir
$(filter-out ./,$(dir $(1)))
endef

# $(1): normalized module prefix, e.g. "docs_GtkFoo_" or ""
# $(2): srcdir for the module, e.g. "docs/" or ""
define def-gtk-doc-module
$(call def-gtk-doc-module-vars,$(_prefix),$(_dir)) \
$(eval $(call def-gtk-doc-module-rules,$(_prefix),$(_dir)))
endef

$(strip $(foreach m,$(DOC_MODULE) $(GTKDOCMODULES), \
  $(eval _prefix := $(call am-gtk-doc-full-module-to-prefix,$(m))) \
  $(eval _dir := $(call am-gtk-doc-full-module-to-dir,$(m))) \
  $(if $(_prefix),$(eval $(_prefix)DOC_MODULE = $(notdir $(m)))) \
  $(call def-gtk-doc-module,$(_prefix),$(_dir)) \
))

#
# Require gtk-doc when making dist
#
if HAVE_GTK_DOC
dist-check-gtkdoc: docs
else
dist-check-gtkdoc:
	@echo "*** gtk-doc is needed to run 'make dist'.         ***"
	@echo "*** gtk-doc was not found when 'configure' ran.   ***"
	@echo "*** please install gtk-doc and rerun 'configure'. ***"
	@false
endif
