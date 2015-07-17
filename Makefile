# Build pvPackage submodules

MODULES += pvCommon
MODULES += pvData
MODULES += normativeTypes
MODULES += pvAccess
MODULES += pvaClient
MODULES += pvaSrv
MODULES += pvDatabase

BUILD_TARGETS = $(MODULES:%=build.%)
HOST_TARGETS = $(MODULES:%=host.%)
TEST_TARGETS = $(MODULES:%=test.%)
PULL_TARGETS = $(MODULES:%=pull.%)
CLEAN_TARGETS = $(MODULES:%=clean.%)

all: $(BUILD_TARGETS)
host: $(HOST_TARGETS)
test: $(TEST_TARGETS)
pull: $(PULL_TARGETS)
clean distclean: $(CLEAN_TARGETS)
rebuild: clean all

$(BUILD_TARGETS): build.% :
	$(MAKE) -C $* all

$(HOST_TARGETS): host.% :
	$(MAKE) -C $* $(EPICS_HOST_ARCH)

$(TEST_TARGETS): test.% :
	$(MAKE) -C $* runtests CROSS_COMPILER_TARGET_ARCHS=

$(PULL_TARGETS): pull.% :
	git submodule update --remote $*

$(CLEAN_TARGETS): clean.% :
	$(MAKE) -C $* distclean

ifeq ($(wildcard RELEASE.local),)
  PVDATABASE = $(realpath pvDatabase)
  PVASRV = $(realpath pvaSrv)
  PVACLIENT = $(realpath pvaClient)
  PVACCESS = $(realpath pvAccess)
  NORMATIVE = $(realpath normativeTypes)
  PVDATA = $(realpath pvData)
  PVCOMMON = $(realpath pvCommon)
  # User must provide EPICS_BASE to create RELEASE.local
else
  include RELEASE.local
endif

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

.PHONY: all host test pull clean distclean rebuild
.PHONY: $(BUILD_TARGETS) $(HOST_TARGETS) $(TEST_TARGETS)
.PHONY: $(PULL_TARGETS) $(CLEAN_TARGETS)

# Module inter-dependencies

build.pvDatabase: build.pvaSrv
build.pvaSrv: build.pvAccess
build.pvaClient: build.pvAccess
build.pvAccess: build.pvData
build.normativeTypes: build.pvData
build.pvData: build.pvCommon
build.pvCommon: RELEASE.local

host.pvDatabase: host.pvaSrv
host.pvaSrv: host.pvAccess
host.pvaClient: host.pvAccess
host.pvAccess: host.pvData
host.normativeTypes: host.pvData
host.pvData: host.pvCommon
host.pvCommon: RELEASE.local

