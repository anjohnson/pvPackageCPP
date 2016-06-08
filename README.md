# EPICS V4 pvPackageCPP super-module

Check out and build the EPICS V4 C++ modules as follows:

```
git clone --recursive git@github.com:anjohnson/pvPackageCPP.git
make -C pvPackageCPP EPICS_BASE=/path/to/your/base-3.x
```

The `Makefile` supports various targets:

* `all` - Build all submodules.
* `host` - Build for host architecture only.
* `test` - Run submodule tests.
* `clean` - Clean all submodules.
* `rebuild` - `make clean` then `make all`.
* `pull` - Update submodules from github.
* `help` - Print this help file

The first time you run `make` it has to create a `RELEASE.local` file,
for which it needs the path to EPICS Base. You can specify that path
on the command-line as above, or by setting an environment variable.
Once the `RELEASE.local` file exists the argument can be omitted from
future executions of `make`. Parallel builds (`make -j`) should work
properly for most targets.

