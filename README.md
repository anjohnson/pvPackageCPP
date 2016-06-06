# EPICS V4 pvPackageCPP super-module

Check out the EPICS V4 modules using the following commands:

```
git clone --recursive git@github.com:anjohnson/pvPackageCPP.git
make -C pvPackageCPP EPICS_BASE=/path/to/your/base-3.x
```

The `Makefile` supports various targets:

* `all` - Build all submodules.
* `host` - Build for host architecture only.
* `test` - Run submodule tests.
* `clean` - Clean all submodules.
* `rebuild` - `clean` then `all`.
* `pull` - Update submodules from github.

The first time you run make it has to create a `RELEASE.local` file,
for which it needs the path to EPICS Base. You can specify that path
on the command-line as above, or by setting an environment variable.

