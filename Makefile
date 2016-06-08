# Build pvPackage submodules

MODULES += pvCommon
MODULES += pvData
MODULES += normativeTypes
MODULES += pvAccess
MODULES += pvaClient
MODULES += pvaSrv
MODULES += pvDatabase
MODULES += example

BUILD_TARGETS = $(MODULES:%=build.%)
HOST_TARGETS = $(MODULES:%=host.%)
TEST_TARGETS = $(MODULES:%=test.%)
PULL_TARGETS = $(MODULES:%=pull.%)
CLEAN_TARGETS = $(MODULES:%=clean.%)
CLEAN_DEP = $(filter clean distclean,$(MAKECMDGOALS))

all: $(BUILD_TARGETS)
host: $(HOST_TARGETS)
test: $(TEST_TARGETS)
pull: $(PULL_TARGETS)
clean distclean: $(CLEAN_TARGETS)
rebuild: clean
	$(MAKE) all

help:
	@cat README.md

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

.PHONY: all host test pull clean distclean rebuild help
.PHONY: $(BUILD_TARGETS) $(HOST_TARGETS) $(TEST_TARGETS)
.PHONY: $(PULL_TARGETS) $(CLEAN_TARGETS)

# Module inter-dependencies

build.example: build.pvDatabase build.pvaSrv build.pvaClient
build.pvDatabase: build.pvAccess
build.pvaSrv: build.pvAccess
build.pvaClient: build.pvAccess build.normativeTypes
build.pvAccess: build.pvData build.pvCommon
build.normativeTypes: build.pvData
build.pvData: RELEASE.local
build.pvCommon: RELEASE.local

host.example: host.pvDatabase host.pvaSrv host.pvaClient
host.pvDatabase: host.pvAccess
host.pvaSrv: host.pvAccess
host.pvaClient: host.pvAccess host.normativeTypes
host.pvAccess: host.pvData host.pvCommon
host.normativeTypes: host.pvData
host.pvData:  RELEASE.local
host.pvCommon: RELEASE.local
