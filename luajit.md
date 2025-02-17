---
tagline: LuaJIT binary
---

## What Lua dialiect is this?

This is OpenResty's LuaJIT 2.1 fork, which means the base language is
[Lua 5.1](http://www.lua.org/manual/5.1/manual.html) plus the following
extensions:

  * [LuaJIT's bit, ffi and jit modules](http://luajit.org/extensions.html#modules)
  * [LuaJIT's extensions from Lua 5.2](http://luajit.org/extensions.html#lua52),
    including those enabled with `DLUAJIT_ENABLE_LUA52COMPAT`
  * [OpenResty's extensions](https://github.com/openresty/luajit2#openresty-extensions)
  * `package.exedir` module which returns the full path of the directory of the executable.
  * `package.exepath` module which returns the full path of the executable.
  * `LUA_PATH` and `LUA_CPATH` supports `'!'` in Linux and OSX too.
  * `LUA_CPATH_DEFAULT` and `LUA_PATH_DEFAULT` were modified as described below.
  * the `terra` module is loaded when running `.t` files from the command line.
  * `SONAME` is not set in `libluajit.so`.

## What is included

LuaJIT binaries (frontend, static library, dynamic library).

Comes bundled with the `luajit` command, which is a simple shell script that
finds and loads the appropriate luajit executable for your platform/arch so
that typing `./luajit` (that's `luajit` on Windows) always works.

LuaJIT was compiled using its original makefile.

## Making portable apps

To make a portable app that can run from any directory out of the box, every
subsystem of the app that needs to open a file must look for that file in
a location relative to the app's directory. This means at least three things:

 * Lua's require() must look in exe-relative dirs first,
 * the OS's shared library loader must look in exe-relative dirs first,
 * the app itself must look for assets, config files, etc. in exe-relative
 dirs first.

The solutions for the first two problems are platform-specific and
are described below. As for the third problem, you can use `package.exedir`.

> To get the location of the _running script_, as opposed to that of the
executable, use [glue.bin]. To add more paths to package.path and
package.cpath at runtime, use [glue.luapath] and [glue.cpath] respectively.

> If you choose to use a LuaJIT binary of your own that doesn't have
`package.exedir`, you can extract the exe's path from `arg[-n]` or use
the more reliable [fs.exedir] if you can have [fs] as a dependency.

### Finding Lua modules

`!\..\..\?.lua;!\..\..\?\init.lua` was added to the default `package.path`
in `luaconf.h`. This allows luapower modules to be found regardless of what
the current directory is, making the distribution portable.

The default `package.cpath` was also modified from `!\?.dll` to `!\clib\?.dll`.
This is to distinguish between Lua/C modules and other binary dependencies
and avoid name clashes on Windows where shared libraries are not prefixed
with `lib`.

The `!` symbol was implemented for Linux and OSX too.

#### The current directory

Lua modules (including Lua/C modules) are searched for in the current
directory ___first___ (on any platform), so the isolation from the host
system is not absolute.

This is the Lua's default setting and although it's arguably a security risk,
it's convenient for when you want to have a single luapower tree, possibly
added to the system PATH, to be shared between many apps. In this case,
starting luajit in the directory of the app makes the app's modules
accessible automatically.

### Finding shared libraries

#### Windows

Windows looks for dlls in the directory of the executable first by default,
and that's where the luapower dlls are, so isolation from system libraries
is acheived automatically in this case.

#### Linux

Linux binaries are built with `rpath=$ORIGIN` which makes ldd look for
shared objects in the directory of the exe first.

`-Wl,--disable-new-dtags` was also used so that it's `RPATH` not `RUNPATH`
that is being set, which makes `dlopen()` work the same from dynamically
loaded code too (this enables eg. `terralib.linklibrary` to link against
luapower libraries by name alone). I'm biting my tongue so hard here...

#### OSX

OSX binaries are built with `rpath=@loader_path` which makes the
dynamic loader look for dylibs in the directory of the exe first.

#### The current directory

The current directory is _not used_ for finding shared libraries
on Linux and OSX. It's only used on Windows, but has lower priority
than the exe's directory.

### Finding [terra] modules

The luajit executable was modified to call `require'terra'` before trying
to run `.t` files at the command line. Also, it loads `.t` files by calling
`_G.loadfile` instead of the C function `lua_loadfile`.

`_G.loadfile` is overriden in `terralib_luapower.lua` to load `.t` files
as Terra source code.

`terralib.lua` was changed to load `terralib_luapower.lua` at the end of the file.

`package.terrapath` is set to match `package.path` in `terralib_luapower.lua`.

[glue.bin]:     glue#glue.bin
[glue.luapath]: glue#glue.luapath
[glue.cpath]:   glue#glue.cpath
[fs.exedir]:    fs#fs.exedir
