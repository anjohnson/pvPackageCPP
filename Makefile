# Build pvPackage submodules

# These are all the submodules
MODULES += pvCommon
MODULES += pvData
MODULES += normativeTypes
MODULES += pvAccess
MODULES += pvaClient
MODULES += pvaSrv
MODULES += pvDatabase
MODULES += example

# Dependencies between the submodules
normativeTypes_DEPENDS_ON = pvData
      pvAccess_DEPENDS_ON = pvData pvCommon
     pvaClient_DEPENDS_ON = pvAccess normativeTypes
        pvaSrv_DEPENDS_ON = pvAccess
    pvDatabase_DEPENDS_ON = pvAccess
       example_DEPENDS_ON = pvDatabase pvaSrv pvaClient

# Generate lists of internal build targets
BUILD_TARGETS = $(MODULES:%=build.%)
HOST_TARGETS = $(MODULES:%=host.%)
TEST_TARGETS = $(MODULES:%=test.%)
PULL_TARGETS = $(MODULES:%=pull.%)
CLEAN_TARGETS = $(MODULES:%=clean.%)
CLEAN_DEP = $(filter clean distclean,$(MAKECMDGOALS))

# Public build targets
all: $(BUILD_TARGETS)
host: $(HOST_TARGETS)
test: $(TEST_TARGETS)
pull: $(PULL_TARGETS)
clean distclean: $(CLEAN_TARGETS)
rebuild: clean
	$(MAKE) all
help:
	@cat README.md

# Internal build targets
$(BUILD_TARGETS): build.% : $(CLEAN_DEP)
	$(MAKE) -C $* all

$(HOST_TARGETS): host.% : $(CLEAN_DEP)
	$(MAKE) -C $* $(EPICS_HOST_ARCH)

$(TEST_TARGETS): test.% :
	$(MAKE) -C $* runtests CROSS_COMPILER_TARGET_ARCHS=

$(PULL_TARGETS): pull.% :
	git submodule update --remote $*

$(CLEAN_TARGETS): clean.% :
	$(MAKE) -C $* distclean

# Automate the build configuration
ifeq ($(wildcard RELEASE.local),)
  # No RELEASE.local file yet, get submodule paths
  PVDATABASE = $(realpath pvDatabase)
  PVASRV = $(realpath pvaSrv)
  PVACLIENT = $(realpath pvaClient)
  PVACCESS = $(realpath pvAccess)
  NORMATIVE = $(realpath normativeTypes)
  PVDATA = $(realpath pvData)
  PVCOMMON = $(realpath pvCommon)
  # User must provide a value for EPICS_BASE
else
  # RELEASE.local exists, import it
  include RELEASE.local
endif

# Check for EPICS_BASE
ifeq ($(wildcard $(EPICS_BASE)),)
  $(error EPICS_BASE is not set/present)
endif

RELEASE.local:
	rm -f RELEASE.local
	echo PVDATABASE = $(PVDATABASE)>  RELEASE.local
	echo PVASRV = $(PVASRV)>>         RELEASE.local
	echo PVACLIENT = $(PVACLIENT)>>   RELEASE.local
	echo PVACCESS = $(PVACCESS)>>     RELEASE.local
	echo NORMATIVE = $(NORMATIVE)>>   RELEASE.local
	echo PVDATA = $(PVDATA)>>         RELEASE.local
	echo PVCOMMON = $(PVCOMMON)>>     RELEASE.local
	echo EPICS_BASE = $(EPICS_BASE)>> RELEASE.local

.PHONY: all host test pull clean distclean rebuild help
.PHONY: $(BUILD_TARGETS) $(HOST_TARGETS) $(TEST_TARGETS)
.PHONY: $(PULL_TARGETS) $(CLEAN_TARGETS)

# Module build dependencies
define MODULE_DEPS_template
  $(1).$(2): $$(foreach dep, $$($(2)_DEPENDS_ON), \
      $$(addprefix $(1).,$$(dep))) RELEASE.local
endef

# Actions for which dependencies matter
ACTIONS = build host

$(foreach action, $(ACTIONS), \
  $(foreach module, $(MODULES), \
    $(eval $(call MODULE_DEPS_template,$(action),$(module)))))
