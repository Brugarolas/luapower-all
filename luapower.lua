
--luapower package reflection library.
--Written by Cosmin Apreutesei. Public Domain.

--[==[

This module uses the many conventions on how modules, C sources, binaries
and documentation is laid out in luapower to extract package and module
metadata.

CONVENTIONS:

	* the git directory of a package is at `.mgit/<package>/.git`.

	* the git work-dir is shared between all packages and it's the current
	directory by default and is configured in luapower.luapower_dir.

	* the currently supported platforms are in luapower.supported_platforms table.

	* a module can signal that it doesn't support the current platform by
	raising an error containing the 'platform not ' or 'arch not ' upon loading.

	* a module can signal that it requires another module to be already loaded
	by raising the error '<module_name> not loaded'.

	* a module's runtime dependencies that are bound to module keys can be
	declared in its `__autoload` metatable field (see glue.autoload).

	* name, description, author and license of a Lua module can be provided
	on the first two line-comments written as:

		-- [<name>:] <description>.
		-- Written By: <author>. <license> [license].
		-- Copyright (C) <author>. <license> [license].

	* submodules can be put in fulders as `<module>/<submodule>.lua`
	(the Lua way) or can be named `<module>_<submodule>.lua` (the luapower way).

	* Lua/C modules are found in `bin/<platform>/clib/<module>.dll|.so`.

	* C sources can be described in the meta file `csrc/<package>/WHAT` which
	must look like this:

		<libname> <version> from <browse-url> (<license> license)
		requires: package1, package2 (platform1 platform2 ...), ...

	the second line is optional and should only list the binary dependencies
	of the library, if any.

	* The WHAT file can also be used to describe Lua modules that are
	developed outside of luapower.

	* packages can be organized into categories in the markdown files
	`.mgit/*-cat.md` which must contain a two-level deep bullet list.
	Any packages that are not listed there will be added automatically to the
	`Misc` category.

	* a package is known if it has a `.mgit/<package>.origin` file.

	* a package is installed if it has a `.mgit/<package>` directory.

	* not installed packages are those known but not installed.

	* modules can be anywhere in the tree except in `/csrc`, `/media`,
	`examples`, `/.mgit`, `/bin`, `/tmp`, `/logs`, `/*-www` and they can be
	in `bin/<platform>/clib`.

	* docs are `*.md` files in Pandoc Markdown format and can be anywhere in
	the tree where modules can be.

	* modules that end in `_test`, `_demo`, `_demo_<arch>`, `_benchmark`
	or `_app` are considered standalone scripts and are never loaded for
	tracking dependencies.

	* packages containing Lua/C modules have an _implicit_ binary dependency
	on the luajit package because they link against the LuaJIT library.

	* packages with a C component must contain a build script named
	`csrc/*/build-<platform>.sh` for each platform that it supports.

	* the main doc file of a package must be named `<package>.md`, but if
	there's only one doc file in the repo, that will be used as main doc file.

	* platforms can be specified in the `platforms` tag of the package's main
	doc file as comma-separated values.

	* binary dependencies can be specified in the `requires` tag of the
	package's main doc file just like in the WHAT file.

	* .dasl files are listed as Lua/ASM modules and are tracked like Lua
	modules and the `dynasm` module is loaded first.

	* .t files are listed as Terra modules and are tracked like Terra modules
	and the `terra` module is loaded first.

	* Lua modules in `ngx` and `resty` dirs are tracked as Lua/Resty modules.

	* Lua files that raise 'ngx not loaded' are tracked as Lua/Resty modules.

STATIC INFO:

	* luapower_dir -> s                     luapower dir
	* mgit_dir -> s                         .mgit dir relative to luapower dir
	* supported_os_platforms -> t           {os -> {platform -> true}}
	* supported_platforms -> t              {platform -> true}
	* builtin_modules -> t                  {module -> true}
	* luajit_builtin_modules -> t           {module -> true}
	* nginx_builtin_modules -> t            {module -> true}
	* loader_modules -> t                   {file_ext -> loader_module_name}
	* enviornments -> t                     {loader_module_name -> env_name}
	* default_license -> s                  default license

SOURCES OF INFORMATION:

	* ffi.os, ffi.abi
	* a module's ffi.load() call tree
	* a module's require() call tree
	* parsing a module for `require(<string_constant>)` calls
	* parsing a module's top comment for name, tagline, author and license
	* the list of `.mgit/<package>.origin` files
	* the list of `.mgit/<package>` directories
	* the parsing of `csrc/<package>/WHAT` file
	* tags parsed from *.md files
	* package category associations parsed from `.mgit/*-cat.md`
	* the output of `git ls-files` (tracked files)
	* the output of `git describe --tags --long --always` (package version)
	* the output of `git --tags --simplify-by-decoration --pretty=%d` (tags)
	* the output of `git describe --tags --abbrev=0` (current tag)
	* the output of `git config --get remote.origin.url` (origin url)
	* the output of `git log -1 --format=%at` (mtime of master branch)
	* the output of `git log -1 --format=%at --follow <file>` (mtime of file)
	* the output of `git log -1 --format=%at <tag>` (mtime of tag)

UTILS:

	powerpath([subpath]) -> s             (path in) luapower dir
	mgitpath([subpath]) -> s              (path in) mgit dir
	git(package, cmd) -> s                get the output of a git command
	gitlines(package, cmd)->iter()->s     iterate the output of a git command
	module_name_cmp(m1, m2) -> t|f        comp func for sorting module names
	walk_tree(t, f)                       tree walker

CACHING:

	memoize_package(fname, f) -> f        memoize a f(pkg[, arg2]) func
	memoize(fname, f) -> f                memoize any func
	clear_cache([pkg])                    clear memoize cache for a pkg or all

PLATFORM:

	check_platform([platform]) -> s       check platform/get current platform
	current_platform() -> s               mingw|linux|osx..32|64

MGIT DIRECTORY INFO:

	known_packages() -> t                 {name -> true}
	installed_packages() -> t             {name -> true}
	not_installed_packages() -> t         {name -> true}

PARSING *-cat.md:

	cats() -> t                           {name=, packages={{name=,note=},...}}
	packages_cats() -> t                  {pkg -> cat}
	package_cat(pkg) -> s                 package's category

TRACKED FILES BREAKDOWN:

	tracked_files([package]) -> t         {path -> package}
	docs([package]) -> t                  {name -> path}
	headerdocs([package]) -> t            {name -> contents}
	modules([package]) -> t               {name -> path}
	scripts([package]) -> t               {name -> path}
	file_types([package]) -> t            {path -> 'module'|'script'|...}
	module_tree(package) -> t             {name=, children=}

PARSING MD FILES:

	docfile_tags(path) -> t               {tag -> val}
	doc_tags([package], doc) -> t         {tag -> val}

PARSING LUA FILES:

	module_requires_runtime(module) -> t  {module -> true}

	modulefile_header(file) -> t          {name=, descr=, author=, license=}
	module_header([package], mod) -> t    {name=, descr=, author=, license=}
	module_headers(package) -> t          {module -> header_table}

PACKAGE REVERSE LOOKUP:

	module_package(mod) -> s              module's package
	doc_package(doc) -> s                 doc's package
	ffi_module_package(mod, pkg, plt)->s  ffi module's package

CSRC DIRECTORY:

	what_tags(package) -> t               {realname=,version=,url=,license=,
	                                        dependencies={platf={dep=true}}}
	bin_deps(package, platform) -> t      {platform -> {package=}}
	build_platforms(package) -> t         {platform -> true}
	bin_platforms(package) -> t           {platform -> true}
	declared_platforms(package) -> t      {platform -> true}
	platforms(package) -> t               {platform -> true}

GIT INFO:

	git_version(package) -> s             current git version
	git_tags(package) -> t                {tag1, ...}
	git_tag(package) -> s                 current tag
	git_origin_url(package) -> s          origin url
	git_master_time(package) -> ts        timestamp of last commit
	git_file_time(package, file) -> ts    timestamp of last modification
	git_tag_time(package, tag) -> ts      timestamp of tag

MODULE DEPENDENCY TRACKING:

	module_loader(mod[, package]) -> s    find a module's loader module if any
	track_module(mod[, package]) -> t     {loaderr=s | mdeps={mod -> true},
	                                        ffi_deps={mod -> true},
	                                        loaders = {mod1, ...}}

UPDATING THE DEPENDENCY DB:

	load_db()                             load luapower_db.lua
	unload_db()                           unload it
	save_db()                             save it
	update_db_on_current_platform([pkg])  update db with local trackings
	update_db(package, [platform], [mod]) update db with local or rpc trackings
	track_module_platform(mod, [package], [platform])
	server_status([platform]) -> t        {platform -> {os=, arch=}}

DEPENDENCY INFO BREAKDOWN:

	module_load_error(mod, package, platform)
	module_platforms(mod, package)
	module_autoloads(mod, package, platform)
	module_autoloaded(mod, package, platform)
	module_requires_loadtime(mod, package, platform)
	module_requires_loadtime_ffi(mod, package, platform)
	module_requires_runtime(mod, package, platform)
	module_requires_alltime(mod, package, platform)

MODULE INDIRECT DEPENDENCIES:

	module_requires_loadtime_tree(mod, package, platform)
	module_requires_loadtime_all(mod, package, platform)
	module_requires_alltime_all(mod, package, platform)
	module_requires_loadtime_int(mod, package, platform)
	module_requires_loadtime_ext(mod, package, platform)

PACKAGE INDIRECT DEPENDENCIES:

	bin_deps_all(package, platform)

REVERSE MODULE DEPENDENCIES:

	module_required_loadtime(mod, package, platform)
	module_required_alltime(mod, package, platform)
	module_required_loadtime_all(mod, package, platform)
	module_required_alltime_all(mod, package, platform)

REVERSE PACKAGE DEPENDENCIES:

	rev_bin_deps(package, platform)
	rev_bin_deps_all(package, platform)

ANALYTIC INFO:

	module_tags() -> t                    {lang=, demo_module=, test_module=}
	package_type(package) -> type         'Lua+ffi'|'Lua/C'|'Lua'|'C'|'other'
	license(package) -> s                 license
	module_tagline(package, mod) -> s     tagline
	build_order(packages, platform) -> t  {pkg1,...}

CONSISTENCY CHECKS:

	duplicate_docs()
	undocumented_package(package)
	load_errors([package], [platform])->t {mod -> err}

GENERATING MGIT DEPS FILES:

	update_mgit_deps([package])           (re)create .deps file(s)

RPC API:

	connect(ip, port[, connect]) -> lp    connect to a RPC server
	lp.osarch() -> os, arch
	lp.exec(func, ...) -> ...
	lp.restart()
	lp.stop()

]==]

local luapower = setmetatable({}, {__index = _G})
setfenv(1, luapower)

local ffi = require'ffi'
local glue = require'glue'
local pp = require'pp'
local fs = require'fs'

--config
------------------------------------------------------------------------------

--locations
luapower_dir = '.'     --the location of the luapower tree to inspect on
mgit_dir = '.mgit'     --relative to luapower_dir

--platforms
supported_os_list = {'mingw', 'linux'} --, 'osx'}
supported_os_platform_list = {
	mingw = {'mingw64'},
	linux = {'linux64'},
	--osx   = {'osx64'},
}
supported_platform_list = {'mingw64', 'linux64'} --, 'osx64'}

supported_os_platforms = {
	mingw = {mingw64 = true},
	linux = {linux64 = true},
	--osx   = {osx64 = true},
}
supported_platforms = {
	mingw64 = true,
	linux64 = true,
	--osx64 = true,
}

servers = {}           --{platform = {'ip|host', port}}

--behavior
auto_update_db = true  --update the db automatically when info is missing
allow_update_db_locally = true --allow dependency tracking on this machine
persistent_cache = false --save memoized results to cache files

default_license = 'Public Domain'

local function plusfile(dir, file)
	if dir == '.' then dir = nil end
	return dir and file and dir..'/'..file or file or dir or '.'
end

--make a path given a luapower_dir-relative path
function powerpath(file)
	return plusfile(luapower_dir, file)
end

--make an abs path given a mgit-dir relative path
function mgitpath(file)
	return plusfile(plusfile(luapower_dir, mgit_dir), file)
end


--persistent memoization with per-package cache invalidation.
------------------------------------------------------------------------------

local nilval = setmetatable({}, {__pwrite = function(_, write) write'nilval' end})
local caches = {} --{fname -> cache_t}
local cache_dir
local function get_cache_dir()
	if not cache_dir then
		if ffi.os == 'Linux' then
			local s = assert(glue.readfile'/proc/self/status')
			local uid = assert(tonumber((s:match'Uid:%s*(%d+)')))
			if fs.is('/run/user/'..uid, 'dir') then --have tmpfs
				cache_dir = '/run/user/'..uid..'/luapower'
			end
		end
		if not cache_dir then
			cache_dir = powerpath'tmp/luapower'
		end
		assert(fs.mkdir(cache_dir, true))
	end
	return cache_dir
end
local function get_cache(fname)
	local cache = caches[fname]
	if not cache then
		cache = {}
		caches[fname] = cache
		cache_dir = get_cache_dir()
		local cache_file = plusfile(cache_dir, fname)
		cache.args = glue.tuples()
		cache.file = cache_file
		cache.retvals = {}
		if persistent_cache and fs.is(cache_file, 'file') then
			local s = assert(glue.readfile(cache_file))
			local pnilval, pcache = loadstring('local nilval={};return nilval,'..s)()
			for args, ret in pairs(pcache) do
				if ret == pnilval then ret = nilval end
				local args = setmetatable(cache.args(glue.unpack(args)), nil)
				cache.retvals[args] = ret
			end
		end
	end
	return cache
end
function memoize(fname, func)
	return function(...)
		local cache = get_cache(fname)
		local args = setmetatable(cache.args(...), nil)
		local ret = cache.retvals[args]
		if ret == nil then
			ret = func(...)
			cache.retvals[args] = ret == nil and nilval or ret
			if persistent_cache then
				glue.writefile(cache.file, pp.format(cache.retvals))
			end
		elseif ret == nilval then
			ret = nil
		end
		return ret
	end
end

--memoize for functions where the first arg is an optional package name.
--cache on those functions can be cleared for individual packages.
function memoize_package(fname, func)
	local funcs = {}
	return function(pkg, ...)
		local fname = (pkg and pkg..'-' or '')..fname
		funcs[fname] = funcs[fname] or memoize(fname, func)
		return funcs[fname](pkg, ...)
	end
end

local free_tracking_states --fw. decl.

--clear memoization caches for a specific package or for all packages.
function clear_cache(pkg)
	local cache_dir = get_cache_dir()
	for fname in fs.dir(cache_dir) do
		if not fname then break end
		if not pkg or glue.starts(fname, pkg..'-') or not fname:find('-', 1, true) then
			if caches[fname] then
				caches[fname].retvals = {}
			end
			if persistent_cache then
				assert(fs.remove(plusfile(cache_dir, fname)))
			end
		end
	end
	free_tracking_states()
end

--other helpers

--filter a table with a filter function(key, value) -> truthy | falsy
local function filter(t, f)
	local dt = {}
	for k,v in pairs(t) do
		if f(k,v) then
			dt[k] = v
		end
	end
	return dt
end


--data acquisition: readers and parsers
--============================================================================


--detect current platform

local platos = {Windows = 'mingw', Linux = 'linux', OSX = 'osx'}
current_platform = memoize('current_platform', function()
	return glue.assert(platos[ffi.os], 'unknown OS %s', ffi.os)
		..(ffi.abi'32bit' and '32' or '64')
end)

--validate a platform if given, or return current platform if not given.
function check_platform(platform)
	if not platform then
		return current_platform()
	end
	return supported_platforms[platform] and platform
end


--find dependencies of a module by tracking `require` and `ffi.load` calls.
------------------------------------------------------------------------------

--modules that we won't track because require'ing them
--is not necessary in any Lua version so there's no point "discovering"
--'luajit' as the package that sources these modules.
builtin_modules = {
	string = true, table = true, coroutine = true, package = true, io = true,
	math = true, os = true, _G = true, debug = true,
}

--install `require` and `ffi.load` trackers -- to be run in a new Lua state.
local function install_trackers(env, builtin_modules, filter, attr)

	local function strip_error(err)
		return err:gsub(':?%s*[\n\r].*', ''):gsub('^.-[\\/]%.%.[\\/]%.%.[\\/]', '')
	end

	--find Lua dependencies of a module by tracing its `require` calls.

	local parent
	local tracks = {} --{module -> {mdeps=, ffi_deps=, autoloads=, loaders=, error=}}
	local new_loader
	local lua_require = require

	function require(m)

		--register the module as a dependency for its parent, if any.
		if parent then
			attr(tracks[parent], 'mdeps')[m] = true
		end

		--require the module directly if it doesn't need tracking.
		if builtin_modules[m] then
			return lua_require(m)
		end

		--save the parent and replace it with this module for re-entry.
		local parent0 = parent
		parent = m

		--get/create this module's tracking table.
		local track = attr(tracks, m)

		--check the error cache before loading the module.
		local ok, ret
		local err = track.loaderr
		if err then
			ok, ret = false, err
			if track.loader then
				new_loader = track.loader
			end
		else
			ok, ret = pcall(lua_require, m)
			if not ok then
				err = strip_error(ret)
				err = err:match'platform not .*'
					or err:match'arch not .*'
					or err:match'[^%s]+ not loaded$'
					or err
				ret = err
			   track.loaderr = err --cache the error for future calls.
				track.loader = err:match'([^%s]+) not loaded$' or nil
				if track.loader then
					new_loader = track.loader
				end
			end
		end

		--restore the parent.
		parent = parent0

		if not ok then
			error(ret, 2)
		end

		--copy the module's autoload table if it has one
		--TODO: dive into the keys of module and check autoload on the keys too!
		--eg. bitmap: 'colortypes.rgbaf' -> 'bitmap_rgbaf'
		local mt = getmetatable(ret)
		local auto = mt and rawget(mt, '__autoload')
		if auto then
			track.autoloads = filter(auto, function(key, mod)
				return type(key) == 'string' and type(mod) == 'string'
			end)
		end

		return ret
	end

	--find C dependencies of a module by tracing the `ffi.load` calls.

	local ffi = lua_require'ffi'
	local ffi_load = ffi.load

	function ffi.load(clib, ...)
		local ok, ret = xpcall(ffi_load, debug.traceback, clib, ...)
		attr(tracks[parent], 'ffi_deps')[clib] = ok
		if not ok then
			error(ret, 2)
		else
			return ret
		end
	end

	--track a module, tracing its require and ffi.load calls.
	function track_module(m)
		parent = nil
		new_loader = nil
		--LuaSec clib modules crash if not loaded in specific order.
		if m:find'^ssl%.' then return end
		pcall(require, m)
		return tracks[m], new_loader
	end

	--load env modules.
	if env then
		local errors
		for m in env:gmatch'[^%s]+' do
			local ok, err = pcall(require, m)
			if not ok then
				errors = errors or {}
				errors[#errors+1] = strip_error(err)
			end
		end
		if errors then
			return nil, table.concat(errors, '\n')
		end
	end

	return true
end

--make or reuse a Lua state for loading modules in a clean environment for
--tracking. the tracker function is installed in the state as the global
--'track_module'. different states are created for each env, mainly because
--terra modules cannot be loaded alongside ffi modules, but also because
--a module raising 'xxx not loaded' cannot be reloaded in the same state.
local states = {} --{env -> state | error}
local function tracking_state(env)
	env = env or false
	local state = states[env]
	if not state then
		local luastate = require'luastate'
		state = luastate.open()
		state:openlibs()
		state:push{[0] = arg[0]} --used to make `glue.bin`
		state:setglobal'arg'
		state:push(install_trackers)
		local ok, err = state:call(env, builtin_modules, filter, glue.attr)
		if not ok then
			state:close()
			state = err
		end
		states[env] = state
	end
	return state
end

function free_tracking_states() --fw. decl.
	for _,state in pairs(states) do
		if type(state) ~= 'string' then
			state:close()
		end
	end
	states = {}
end

local function track_module_in_state(state, ...)
	if type(state) == 'string' then
		return {loaderr = 'could not create tracking environment: '..state}
	end
	state:getglobal'track_module'
	return state:call(...)
end

--track a module in a Lua state which is reused on future calls.
--if new loaders are found, tracking is retried with the loaders loaded first.
local function track_module(m, env)
	assert(m, 'module required')
	local state = tracking_state(env)
	local track, new_loader = track_module_in_state(state, m)
	if new_loader then
		return track_module(m, env and env..' '..new_loader or new_loader)
	end
	if track then
		track.env = env
	end
	return track
end

--dependency tracking based on parsing
------------------------------------------------------------------------------

--built-in modules that don't have parsable source code.
luajit_builtin_modules = {
	--luajit built-ins.
	ffi = true, bit = true, jit = true,
	['jit.util'] = true, ['jit.profile'] = true,
	--openresty built-ins.
	['table.new'] = true,
	['table.isempty'] = true,
	['table.isarray'] = true,
	['table.nkeys'] = true,
	['table.clone'] = true,
	['thread.exdata'] = true,
	--luapower built-ins.
	['package.exedir'] = true,
	['package.exepath'] = true,
}

nginx_builtin_modules = {
}

module_requires_runtime_parsed = memoize('module_requires_runtime_parsed', function(m) --direct dependencies
	local t = {}
	if    builtin_modules[m]
		or luajit_builtin_modules[m]
		or nginx_builtin_modules[m]
	then
		return t
	end
	local path =
		--search for .lua files in standard path
		package.searchpath(m, package.path)
		--search for .dasl files in the same path as .lua files
		or package.searchpath(m, package.path:gsub('%.lua', '.dasl'))
	if not path then
		return t
	end
	local s = assert(glue.readfile(path))
	--delete long comments
	s = s:gsub('%-%-%[(=*)%[.*%]%1%]', '')
	--delete long strings
	s = s:gsub('%-%-%[%[.*%]%]', '')
	--delete short comments
	s = s:gsub('%-%-[^\n\r]*', '')
	--delete the demo section (horrible parsing)
	s = s:gsub('[\r\n]if not %.%.%. then%s+.-%s+end', '')
	--local xxx = require'xxx'
	for m in s:gmatch'[ \t]+local %w+[ \t]+=[ \t]+require%s*(%b\'\')' do
		t[m:sub(2,-2)] = true
	end
	--local xxx = require"xxx"
	for m in s:gmatch'[ \t]+local %w+[ \t]+=[ \t]+require%s*(%b"")' do
		t[m:sub(2,-2)] = true
	end
	--local xxx = require("xxx") or local xxx = require('xxx')
	for m in s:gmatch'[ \t]+local %w+[ \t]+=[ \t]+require%s*(%b())' do
		m = glue.trim(m:sub(2,-2))
		if m:find'^%b\'\'$' or m:find'^%b""$' then
			m = m:sub(2,-2)
			if m:find'^[a-z0-9%.]+$' then
				t[m] = true
			end
		end
	end
	return t
end)


--module header parsing
------------------------------------------------------------------------------

local function parse_author_license_line(s, c)
	local c = c and '%s*%-%-' or ''
	local author, license =
		s:match('^'..c..'%s*[Ww]ritten%s+[Bb]y%:?%s*([^%.]+)%.%s*([^%.]+)')
	if not license then
		author, license =
			s:match('^'..c..'%s*[Cc]opyright%s*%([Cc]%)%s*([^%.]+)%.%s*([^%.]+)')
	end
	if license then
		license = license:gsub('%s*[Ll]icense:?%s*', '')
		if license:lower() == 'public domain' then
			license = 'Public Domain'
		end
	end
	return author, license
end

local function parse_name_descr_line(s, c)
	local c = c and '%s*%-%-' or ''
	local name, descr =
		s:match('^'..c..'%s*([^%:]+)%:%s*(.*)') -- '--name: descr'
	if not name then
		descr = c ~= ''
			and s:match'^%s*%-%-%[%[%s*(.-)%s*%]%]%[%-]+%s*$'
			or nil -- '--[[ descr ]]--' (ffi_reflect.lua)
		descr = descr or s:match('^'..c..'%s*([^%[].*)') -- '--descr'
	end
	descr = descr and descr:gsub('%.$', '')
	return name, descr
end

local function parse_module_header(file)
	local t = {}
	local f = io.open(file, 'r')
	--TODO: check if the module is a .lua file first (what else can it be?).
	--TODO: parse "Author: XXX"
	--TODO: parse "License: XXX"
	--TODO: parse all comment lines before a non-comment line starts.
	--TODO: parse long comments too.
	if f then
		local s1 = f:read'*l'
		while s1 and (
			s1:find'^%s*$' --skip empty lines
			or s1:find'^%s*[%-=]+%s*$' --skip "section" delimiters (dynasm.lua)
		) do
			s1 = f:read'*l'
		end
		if s1 then
			t.name, t.descr = parse_name_descr_line(s1, true)
			if t.descr then
				local s2 = f:read'*l'
				if s2 then
					t.author, t.license = parse_author_license_line(s2, true)
				end
			else
				local sep = s1:match'%s*%-%-%[([=]*)%[%s*$' -- '--[==['
				if sep then --in-header doc (terra/dynarray.lua).
					local dt = {}
					table.insert(dt, s1)
					while true do
						s1 = f:read'*l'
						if not s1 then
							break
						end
						if not t.descr then
							t.name, t.descr = parse_name_descr_line(s1)
						end
						if not t.license then
							t.author, t.license = parse_author_license_line(s1)
						end
						table.insert(dt, s1)
						if s1:match('^(.-)%s*%]'..sep..'%]%s*$') then -- ']==]'
							break
						end
					end
					t.doc = table.concat(dt, '\n')
				end
			end
		end
		f:close()
	end
	return t
end

--comparison function for table.sort() for modules: sorts built-ins first.
------------------------------------------------------------------------------

function module_name_cmp(a, b)
	if builtin_modules[a] == builtin_modules[b] or
		luajit_builtin_modules[a] == luajit_builtin_modules[b]
	then
		--if a and be are in the same class, compare their names
		return a < b
	else
		--compare classes (std. vs non-std. module)
		return not (builtin_modules[b] or luajit_builtin_modules[b])
	end
end


--filesystem reader
------------------------------------------------------------------------------

--recursive dir() -> iter() -> filename, path, mode
local function dir(p0, recurse)
	assert(p0)
	local t = {}
	local function rec(p)
		local dp = p0 .. (p and '/' .. p or '')
		for f,d in fs.dir(dp) do
			if f then
				local ftype = d:attr'type'
				table.insert(t, {f, p, ftype})
				if recurse and ftype == 'dir' then
					rec((p and p .. '/' .. f or f))
				end
			end
		end
	end
	rec()
	local i = 0
	return function()
		i = i + 1
		if not t[i] then return end
		return unpack(t[i], 1, 3)
	end
end

--path/dir/file -> path/dir, file
local function split_path(path)
	local filename = path:match'([^/]*)$'
	local n = #path - #filename - 1
	if n > 1 then n = n - 1 end --remove trailing '/' if the path is not '/'
	return path:sub(1, n), filename
end

--open a file and return a gimme-the-next-line function and a close function.
local function more(filename)
	local f, err = io.open(filename, 'r')
	if not f then return nil, err end
	local function more()
		local s = f:read'*l'
		if not s then f:close(); f = nil end
		return s
	end
	local function close()
		if f then f:close() end
	end
	return more, close
end


--git command output readers
------------------------------------------------------------------------------

--read a cmd output to a line iterator
local function pipe_lines(cmd)
	if ffi.os == 'Windows' then
		cmd = cmd .. ' 2> nul'
	else
		cmd = cmd .. ' 2> /dev/null'
	end
	local t = {}
	glue.fcall(function(finally)
		local f = assert(io.popen(cmd, 'r'))
		finally(function()
			f:close()
		end)
		f:setvbuf'full'
		for line in f:lines() do
			t[#t+1] = line
		end
	end)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

--read a cmd output to a string
local function read_pipe(cmd)
	local t = {}
	for line in pipe_lines(cmd) do
		t[#t+1] = line
	end
	return table.concat(t, '\n')
end

local function git_dir(package)
	return mgitpath(package..'/.git')
end

--git command string for a package repo
local function gitp(package, args)
	local git = ffi.os == 'Windows' and 'git.exe' or 'git'
	return git..' --git-dir="'..git_dir(package)..'" '..args
end

--execute function in a different current-directory.
local function in_dir(dir, func, ...)
	local pwd = assert(fs.cd())
	assert(fs.cd(dir))
	local function pass(ok, ...)
		fs.cd(pwd)
		assert(ok, ...)
		return ...
	end
	return pass(glue.pcall(func, ...))
end

function git(package, cmd)
	return in_dir(powerpath(), read_pipe, gitp(package, cmd))
end

function gitlines(package, cmd)
	return in_dir(powerpath(), pipe_lines, gitp(package, cmd))
end


--module finders
------------------------------------------------------------------------------

--path/*.lua -> Lua module name
local function lua_module_name(path)
	return path:gsub('/', '.'):match('(.-)%.lua$')
end

--path/*.dasl -> dasl module name
local function dasl_module_name(path)
	return path:gsub('/', '.'):match('(.-)%.dasl$')
end

--path/*.dll|.so -> C module name
local function c_module_name(path)
	local ext = package.cpath:match'%?%.([^;]+)' --dll, so
	local name = path:match('bin/[^/]+/clib/(.-)%.'..ext..'$')
	return name and name:gsub('/', '.')
end

--path/*.t -> Terra module name
local function terra_module_name(path)
	return path:gsub('/', '.'):match('(.-)%.t$')
end

--check if a file is a module and if it is, return the module name
local function module_name(path)
	path = tostring(path)
	return
		lua_module_name(path)
		or dasl_module_name(path)
		or c_module_name(path)
		or terra_module_name(path)
end

--'module_submodule' -> 'module'
--'module.submodule' -> 'module'
local function parent_module_name(mod)
	local parent = mod:match'(.-)[_%.][^_%.]+$'
	if not parent or parent == '' then return end
	return parent
end


--tree builder and tree walker patterns
------------------------------------------------------------------------------

--tree builder based on a function that produces names and a function that
--resolves the parent name of a name.
--returns a tree of form:
--		{name = true, children = {name = NAME, children = ...}}
local function build_tree(get_names, get_parent)
	local parents = {}
	for name in get_names() do
		parents[name] = get_parent(name) or true
	end
	local root = {name = true}
	local function add_children(pnode)
		for name, parent in pairs(parents) do
			if parent == pnode.name then
				local node = {name = name}
				pnode.children = pnode.children or {}
				table.insert(pnode.children, node)
				add_children(node)
			end
		end
	end
	add_children(root)
	return root
end

--tree walker: calls f(node, level, parent_node, node_index) for each node.
--depth-first traversal.
function walk_tree(t, f)
	local function walk_children(pnode, level)
		if type(pnode) ~= 'table' then return end
		if not pnode.children then return end
		for i,node in ipairs(pnode.children) do
			f(node, level, pnode, i)
			walk_children(node, level + 1)
		end
	end
	walk_children(t, 0)
end


--WHAT file parser
------------------------------------------------------------------------------

--parse '<pkg1>, <pkg2> (<platform1> ...), ...' -> {platform->{pkg->true}}
local function parse_requires_list(values, deps)
	deps = deps or {}
	for s in glue.gsplit(values, ',') do
		s = glue.trim(s)
		if s ~= '' then
			local s1, ps =
				s:match'^([^%(]+)%s*%(%s*([^%)]+)%s*%)' --'pkg (platform1 ...)'
			if ps then
				s = glue.trim(s1)
				for platform in glue.gsplit(ps, '%s+') do
					glue.attr(deps, platform)[s] = true
				end
			else
				for platform in pairs(supported_platforms) do
					glue.attr(deps, platform)[s] = true
				end
			end
		end
	end
	return deps
end

--parse 'lib (mod1 ...)' -> {lib->{module->true}}
local function parse_modules_list(values, modules)
	modules = modules or {} --{lib->{module->true}}
	for s in glue.gsplit(values, ',') do
		s = glue.trim(s)
		if s ~= '' then
			local s, ps =
				s:match'^([^%(]+)%s*%(%s*([^%)]+)%s*%)' --'lib (mod1 ...)'
			if ps then
				s = glue.trim(s)
				modules[s] = {}
				for mod in glue.gsplit(ps, '%s+') do
					modules[s][mod] = true
				end
			else
				error('Invalid WHAT file '..what_file)
			end
		end
	end
	return modules
end

--WHAT file -> {realname=, version=, url=, license=, dependencies={d1,...}}
local function parse_what_file(what_file)
	local t = {}
	local more, close = assert(more(what_file))

	--parse the first line which has the format:
	--		'<realname> <version> from <url> (<license>)'
	local s = assert(more(), 'invalid WHAT file '.. what_file)
	t.realname, t.version, t.url, t.license =
		s:match('^%s*(.-)%s+(.-)%s+from%s+(.-)%s+%((.*)%)')
	if not t.realname then
		error('invalid WHAT file '..what_file)
	end
	t.license = t.license and
		t.license:match('^(.-)%s+'..glue.esc('license', '*i')..'$')
		or t.license
	t.license =
		t.license:match('^'..glue.esc('public domain', '*i')..'$')
		and 'Public Domain' or t.license

	--parse next lines if they have the format:
	-- 'modules: lib1 (mod1 mod2 ...), ...'
	-- 'requires: <pkg1>, <pkg2> (<platform1> ...), ...'
	t.dependencies = {} -- {platform -> {dep -> true}}
	t.modules = {} -- {platform -> {mod -> true}}
	while true do
		local s = more()
		if not s then break end
		local directive, values = s:match'^([^:]*):(.*)' --requires:, modules:
		if directive then
			if directive == 'requires' then
				parse_requires_list(values, t.dependencies)
			elseif directive == 'modules' then
				parse_modules_list(values, t.modules)
			end
		end
	end

	close()
	return t
end


--markdown yaml header parser
------------------------------------------------------------------------------

--"key <separator> value" -> key, value
local function split_kv(s, sep)
	sep = glue.esc(sep)
	local k,v = s:match('^([^'..sep..']*)'..sep..'(.*)$')
	k = k and glue.trim(k)
	if not k then return end
	v = glue.trim(v)
	if v == '' then v = true end --values default to true in pandoc
	return k,v
end

--parse the yaml header of a pandoc .md file, enclosed between '---\n'
local function parse_md_file(md_file)
	local docname = md_file:match'([^/\\]+)%.md$'
	local t = {}
	local more, close = more(md_file)
	if not more or not more():find '^---' then
		t.title = docname
		if more then
			close()
		end
		return t
	end
	for s in more do
		if s:find'^---' then break end
		local k,v = split_kv(s, ':')
		if k then
			if k == 'requires' then
				t.dependencies = parse_requires_list(v)
			elseif k == 'modules' then
				t.modules = parse_modules_list(v)
			else
				t[k] = v
			end
		end
	end
	t.title = t.title or docname --set default title
	close()
	return t
end


--category file parser from the luapower-repos package
------------------------------------------------------------------------------

--parse the table of contents file into a list of categories and docs.
cats = memoize_package('cats', function(package)
	local cats = {}
	local pkgs = filter(installed_packages(),
		function(pkg) return known_packages()[pkg] end)
	local uncat = glue.update({}, pkgs)
	for file in fs.dir(mgitpath()) do
		if not file then break end
		if file:find'%-cat%.md$' then
			local more, close = assert(more(powerpath(mgitpath(file))))
			local lastcat
			for s in more do
				local pkg, note =
					s:match'^%s*%*%s*%[([^%]]+)%]%s*(.-)%s*$' -- " * [name]"
				if pkg then
					if pkgs[pkg] then --skip unknown packages (typos, etc.)
						note = note ~= '' and note or nil
						table.insert(lastcat.packages, {name = pkg, note = note})
						uncat[pkg] = nil
					end
				else
					local cat = s:match'^%s*%*%s*(.-)%s*$' -- " * name"
					if cat then
						lastcat = cats[cat]
						if not lastcat then
							lastcat = {name = cat, packages = {}}
							table.insert(cats, lastcat)
							cats[cat] = lastcat
						end
					end
				end
			end
			close()
		end
	end
	if next(uncat) then
		local misc = {}
		for i, pkg in ipairs(glue.keys(uncat, true)) do
			table.insert(misc, {name = pkg})
		end
		table.insert(cats, {name = 'Misc', packages = misc})
	end
	return cats
end)


--data acquisition: logic and collection
--============================================================================


--packages and their files
------------------------------------------------------------------------------

--.mgit/<name>.origin -> {name = true}
known_packages = memoize('known_packages', function()
	local t = {}
	for f in dir(powerpath(mgitpath())) do
		local s = f:match'^(.-)%.origin$'
		if s then t[s] = true end
	end
	return t
end)

--.mgit/<name>/ -> {name = true}
installed_packages = memoize('installed_packages', function()
	local t = {}
	for f, _, ftype in dir(powerpath(mgitpath())) do
		if ftype == 'dir' then
			if fs.is(powerpath(git_dir(f)), 'dir') then
				t[f] = true
			end
		end
	end
	return t
end)

--(known - installed) -> not installed
not_installed_packages = memoize('not_installed_packages', function()
	local installed = installed_packages()
	return filter(known_packages(),
		function(pkg) return not installed[pkg] end)
end)

--wrapper for any function(package, ...) which returns a table with keys that
--are unique accross all packages. it makes the package argument optional
--so that if not given, function(package) is called repeatedly for each
--installed package and the results are accumulated into a single table.
local function opt_package(func)
	return function(package, ...)
		if package then
			return func(package, ...)
		end
		local t = {}
		for package in glue.sortedpairs(installed_packages()) do
			glue.update(t, func(package, ...))
		end
		return t
	end
end

--memoize for functions where the first arg, package, is optional.
local function memoize_opt_package(fname, func)
	return memoize(fname..'_opt_package', opt_package(memoize_package(fname, func)))
end

--git ls-files -> {path = package}
tracked_files = memoize_opt_package('tracked_files', function(package)
	local t = {}
	for path in gitlines(package, 'ls-files') do
		t[path] = package
	end
	return t
end)


--tracked files breakdown: modules, scripts, docs
------------------------------------------------------------------------------

--check if a path is valid for containing Lua or Terra modules.
local function is_module_path(p)
	if not p then return true end
	return not (
		   p:find'^bin/'     --can't have modules in bin
		or p:find'^csrc/'    --can't have modules in csrc
		or p:find'^media/'   --can't have modules in media
		or p:find'/examples/'--can't have modules in examples
		or p:find'^tmp/'     --can't have modules in tmp
		or p:find'^logs/'    --can't have modules in logs
		or p:find'^.-%-www/' --can't have modules in www dirs
		or p:find'^%.mgit/'  --can't have modules in .mgit
	)
end

--check if a path is valid for containing OpenResty modules.
local function is_resty_module_path(p)
	return not p or (p:find'^resty/' or p:find'^ngx/') and true or false
end

--check if a path is valid for containing platform-specific modules
--(optionally test for a specific platform) and return that platform.
local function module_platform_path(p, platform)
	platform = platform and check_platform(platform)
	return platform and p:match('^bin/('..platform..')/clib/') --Lua/C modules
end

--check if a path is valid for containing docs.
--docs can be anywhere except in a few "reserved" places.
local function is_doc_path(p)
	return is_module_path(p)
end

--check if a name is a loadable module as opposed to a script or app.
--*_demo, *_test, *_benchmark and *_app modules are excluded from tracking.
local function is_module(mod)
	return not (
		mod:find'_test$'
		or mod:find'_demo$'
		or mod:find'_demo_.*$' --"demo_<arch>"
		or mod:find'_benchmark$'
		or mod:find'_app$'
	)
end

local function doc_name(path)
	return path:gsub('/', '.'):match'^(.-)%.md$'
end

--tracked <doc>.md -> {doc = path}
docs = memoize_opt_package('docs', function(package)
	local t = {}
	for path in pairs(tracked_files(package)) do
		if is_doc_path(path) then
			local name = doc_name(path)
			if name then
				t[name] = path
			end
		end
	end
	return t
end)

local function modules_(package, platform, should_be_module)
	local t = {}
	local function add_module(mod, plat, path)
		if is_module(mod) == should_be_module then
			if plat and not platform then
				if not t[mod] then
					local pt = {}
					t[mod] = pt
					--sometimes we don't care about which path it is...
					setmetatable(pt, {__tostring = function() return path end})
				end
				t[mod][plat] = path
			else
				t[mod] = path
			end
		end
	end
	for path in pairs(tracked_files(package)) do
		local found = is_module_path(path)
		local plat = not found and module_platform_path(path, platform)
		if found or plat then
			local mod = module_name(path)
			if mod then
				if c_module_name(path) then --can contain submodules
					local mods = what_tags(package).modules
					if mods and mods[mod] then
						for mod in pairs(mods[mod]) do
							add_module(mod, plat, path)
						end
					else
						add_module(mod, plat, path)
					end
				else
					add_module(mod, plat, path)
				end
			end
		end
	end
	--add the built-ins to the list of modules for the 'luajit' package
	if should_be_module and package == 'luajit' then
		glue.update(t, builtin_modules, luajit_builtin_modules)
	end
	return t
end

--tracked <mod>.lua | bin/<platform>/clib|lua/<mod>.so|.lua -> {mod=path}
--note: platform is optional: if not given, for the platform-specific modules
--all the paths are returned in a table {platform = path}.
modules = memoize_opt_package('modules', function(package, platform)
	return modules_(package, platform, true)
end)

--tracked <script>.lua -> {script = path}
scripts = memoize_opt_package('scripts', function(package)
	return modules_(package, nil, false)
end)

--tracked file -> {path = 'module'|'script'|'doc'|'unknown'}
file_types = memoize_opt_package('file_types', function(package)
	local t = {}
	for path in pairs(tracked_files(package)) do
		if is_module_path(path) then
			local mod = module_name(path)
			if mod then
				t[path] = is_module(mod) and 'module' or 'script'
			elseif is_doc_path(path) and doc_name(path) then
				t[path] = 'doc'
			else
				t[path] = 'unknown'
			end
		end
	end
	return t
end)

--module logical (name-wise) tree
------------------------------------------------------------------------------

--first ancestor module (parent, grandad etc.) that actually exists
--in the same package (or in all packages).
--module hierarchy is based on naming conventions mod.submod and mod_submod
--and has nothing to do with how modules are required by one another.
local function module_parent_(package, mod)
	local parent = parent_module_name(mod)
	if not parent then return end
	return modules(package)[parent] and parent
		or module_parent_(package, parent)
end
local module_parent = memoize_package('module_parent', module_parent_)

--build a module tree for a package (or for all packages)
module_tree = memoize_package('module_tree', function(package, platform)
	local function get_names() return pairs(modules(package, platform)) end
	local function get_parent(mod) return module_parent(package, mod) end
	return build_tree(get_names, get_parent)
end)

--doc tags
------------------------------------------------------------------------------

docfile_tags = memoize('docfile_tags', parse_md_file)

--tracked <doc>.md -> {title='', other yaml tags...}
doc_tags = memoize_package('doc_tags', function(package, doc)
	local path = docs(package)[doc]
	return path and docfile_tags(powerpath(path))
end)


--module header tags
------------------------------------------------------------------------------

modulefile_header = memoize('modulefile_header', parse_module_header)

module_header = memoize_package('module_header', function(package, mod)
	local path = modules(package)[mod]
	return type(path) == 'string' and modulefile_header(powerpath(path)) or {}
end)

module_headers = memoize_package('module_headers', function(package)
	local t = {}
	for mod in pairs(modules(package)) do
		local h = module_header(package, mod)
		h.module = mod
		t[#t+1] = h
	end
	table.sort(t, function(t1, t2)
		local s1 = t1.name or t1.module
		local s2 = t2.name or t2.module
		return s1 < s2
	end)
	return t
end)

docheaders = memoize_opt_package('docheaders', function(package)
	local t = {}
	for mod in pairs(modules(package)) do
		t[mod] = module_header(package, mod)
	end
	return t
end)

--reverse lookups
------------------------------------------------------------------------------

--known modules that don't subscribe to luapower naming rules
local known_module_packages = {
	jit = 'luajit',
	strict = 'luajit',
	mime = 'socket',
	ltn12 = 'socket',
	lua_h = 'lua-headers',
	luajit_h = 'lua-headers',
	dasm = 'dynasm',
	terralib = 'terra',
	--TODO: fix these names and remove them from here!
	im_boxblur = 'blur',
	im_stackblur = 'blur',
	obj_loader = 'obj_parser',
	gl11 = 'opengl',
	gl = 'opengl',
	glu = 'opengl',
	glx = 'xlib',
}

--find the pacakge which contains a specific module.
module_package = memoize('module_package', function(mod)
	assert(mod, 'module required')
	--shortcut: builtin module
	if builtin_modules[mod] then return end --no reporting for Lua built-ins
	if luajit_builtin_modules[mod] then return 'luajit' end
	if nginx_builtin_modules[mod] then return 'nginx' end
	--shortcut: find the package that matches the module name or one of its
	--prefixes (which is a possible parent module).
	local mod1 = mod
	while mod1 do
		if installed_packages()[mod1] and modules(mod1)[mod] then
			return mod1 --the module is indeed in the package
		end
		mod1 = parent_module_name(mod1)
	end
	--the slow way: look in all packages for the module
	--print('going slow for '..mod..'...')
	local path = modules()[mod]
	return path and tracked_files()[tostring(path)]
end)

--memoize for functions of type f(mod, package) where package is optional.
--like memoize_package() but for when the package arg is the second arg.
local function memoize_mod_package(fname, func)
	local memfunc = memoize_package(fname, function(package, mod)
		return func(mod, package)
	end)
	return function(mod, package)
		package = package or module_package(mod)
		return memfunc(package, mod)
	end
end

--find the package which contains a specific doc.
doc_package = function(doc)
	--shortcut: package doc
	if installed_packages()[doc] and docs(doc)[doc] then
		return doc
	end
	--the slow way: look in all packages for the doc
	--print('going slow for '..doc..'...')
	local path = docs()[doc]
	return path and tracked_files()[path]
end

--find the package which contains a ffi.load()'able module.
local libfmt = {
	mingw32 = '%s.dll', mingw64 = '%s.dll',
	linux32 = 'lib%s.so', linux64 = 'lib%s.so',
	osx32 = 'lib%s.dylib', osx64 = 'lib%s.dylib',
}

local function ffi_module_in_package(mod, package, platform)
	local path = 'bin/'..platform..'/'..string.format(libfmt, mod)
	return tracked_files(package)[path] and true or false
end

ffi_module_package = memoize('ffi_module_package', function(mod, package, platform, ...)
	platform = check_platform(platform)
	if not platform then return end
	--shortcut: try current package.
	if package and ffi_module_in_package(mod, package, platform) then
		return package
	end
	--shortcut: find the package that matches the module name.
	if installed_packages()[mod] then
		if ffi_module_in_package(mod, mod, platform) then
			return mod
		end
	end
	--slow way: look in all packages
	for package in pairs(installed_packages()) do
		if ffi_module_in_package(mod, package, platform) then
			return package
		end
	end
end)


--package csrc info
------------------------------------------------------------------------------

--check if the package has a dir named `csrc/PACKAGE`, and return that path.
local csrc_dir = memoize_package('csrc_dir', function(package)
	if fs.is(powerpath('csrc/'..package), 'dir') then
		return 'csrc/'..package
	end
end)

--csrc/*/WHAT -> {tag=val,...}
what_tags = memoize_package('what_tags', function(package)
	if not csrc_dir(package) then return end
	local what_file = powerpath(csrc_dir(package) .. '/WHAT')
	return glue.canopen(what_file) and parse_what_file(what_file)
end)

local has_luac_modules = memoize_package('has_luac_modules', function(package)
	for mod, path in pairs(modules(package)) do
		if c_module_name(tostring(path)) then
			return true
		end
	end
end)

--package dependencies as declared in the WHAT file.
--they can also be declared in the header section of the package doc file.
bin_deps = memoize_package('bin_deps', function(package, platform)
	platform = check_platform(platform)
	if not platform then return {} end
	local t1 = what_tags(package) and what_tags(package).dependencies
	local t2 = doc_tags(package, package) and doc_tags(package, package).dependencies
	local t = glue.update({}, t1 and t1[platform], t2 and t2[platform])
	--packages containing Lua/C modules have an _implicit_ binary dependency
	--on the luajit package because they link against the LuaJIT library.
	if has_luac_modules(package) then
		t.luajit = true
	end
	return t
end)

--supported platforms can be inferred from the name of the build script:
--csrc/*/build-<platform>.sh -> {platform = true,...}
build_platforms = memoize_opt_package('build_platforms', function(package)
	local t = {}
	if csrc_dir(package) then
		for path in pairs(tracked_files(package)) do
			local s = glue.esc(csrc_dir(package)..'/build-')
			local platform =
				path:match('^'..s..'(.-)%.sh$') or
				path:match('^'..s..'(.-)%.cmd$')
			if platform and supported_platforms[platform] then
				t[platform] = true
			end
		end
	end
	return t
end)

--platforms can also be inferred from the presence of files in bin/<platform>.
bin_platforms = memoize_opt_package('bin_platforms', function(package)
	local t = {}
	for path in pairs(tracked_files(package)) do
		local platform = path:match('^bin/([^/]+)/.')
		if platform then
			t[platform] = true
		end
	end
	return t
end)

--platforms can be specified in the 'platforms' tag of the package doc file:
--<package>.md:platforms -> {platform = true,...}
declared_platforms = memoize_opt_package('declared_platforms', function(package)
	local t = {}
	local tags = doc_tags(package, package)
	if tags and tags.platforms then
		for platform in glue.gsplit(tags.platforms, ',') do
			platform = glue.trim(platform)
			if platform ~= '' then
				local pt = supported_os_platforms[platform]
				if pt then
					glue.update(t, pt)
				else
					t[platform] = true
				end
			end
		end
	end
	return t
end)

platforms = memoize_opt_package('platforms', function(package)
	return glue.update({},
		build_platforms(package),
		bin_platforms(package),
		declared_platforms(package))
end)


--package git info
------------------------------------------------------------------------------

--current git version
git_version = memoize_package('git_version', function(package)
	return git(package, 'describe --tags --long --always')
end)

--list of tags in order
git_tags = memoize_package('git_tags', function(package)
	local t = {}
	local opt = 'log --tags --simplify-by-decoration --pretty=%d'
	for s in gitlines(package, opt) do
		local tag = s:match'tag: ([^%),]+)'
		if tag then
			t[#t+1] = tag
		end
	end
	return glue.reverse(t)
end)

--current tag
git_tag = memoize_package('git_tag', function(package)
	return git(package, 'describe --tags --abbrev=0')
end)

git_origin_url = memoize_package('git_origin_url', function(package)
	return git(package, 'config --get remote.origin.url')
end)

local function git_log_time(package, args)
	return tonumber(glue.trim(git(package, 'log -1 --format=%at '..args)))
end

git_master_time = memoize_package('git_master_time', function(package)
	return git_log_time(package, '')
end)

git_file_time = memoize_package('git_file_time', function(package, file)
	return git_log_time(package, '--follow \''..file..'\'')
end)

git_tag_time = memoize_package('git_tag_time', function(package, tag)
	return git_log_time(package, tag)
end)


--track_module override: find the module's loader based on its file extension
------------------------------------------------------------------------------

--modules with extensions other than Lua need a require() loader to be
--installed first. that loader is usually installed by loading another module.
loader_modules = {
	dasl = 'dynasm',
	t    = 'terra',
}

function module_loader(mod, package)
	package = package or module_package(mod)
	local path = modules(package)[mod]
	if not path or path == true then return end
	if type(path) == 'table' then
		path = path[current_platform()]
	end
	if is_resty_module_path(path) then
		return 'ngx'
	end
	local ext = path:match'%.(.*)$'
	if not ext then return end
	return loader_modules[ext]
end

local track_module_ = track_module
luapower.track_module = memoize_mod_package('track_module', function(mod, package)
	package = package or module_package(mod)
	local loader_mod = module_loader(mod, package)
	return track_module_(mod, loader_mod, env)
end)


--track_module_platform: track dependencies on multiple platforms by:
--1) using tracking data recorded in a local database file.
--2) tracking live on a RPC server that runs on the needed platform.
------------------------------------------------------------------------------

--NOTE: initializing with false instead of nil for compat. with strict.lua.
local db = false --{platform = {package = {module = tracking_table}}}

local function dbfile()
	return powerpath'luapower_db.lua'
end

function load_db()
	if db then return end
	local dbfile = dbfile()
	db = glue.canopen(dbfile) and assert(loadfile(dbfile))() or {}
end

function unload_db()
	db = nil
end

function save_db()
	assert(db, 'db not loaded')
	local pp = require'pp'
	local dbfile = dbfile()
	local opt = {indent = '\t', sort_keys = true}
	local write = coroutine.wrap(function()
		 coroutine.yield'return '
		 pp.write(coroutine.yield, db, opt)
	end)
	glue.writefile(dbfile, write, nil, dbfile..'.tmp')
end

--NOTE: this function has no upvalues so that it can be uploaded and run
--on a RPC server. the `package` arg is an optional filter.
local function get_tracking_data(package, mod)
	local lp = require'luapower'
	local glue = require'glue'
	local t = {}
	local function track_modules(package)
		local t = glue.attr(t, package)
		local plt = platforms(package)
		--only track if the package itself supports this platform
		if not next(plt) or plt[current_platform()] then
			for m in pairs(lp.modules(package)) do
				if not mod or m == mod then
					t[m] = lp.track_module(m, package)
				end
			end
		end
	end
	if not package then
		for package in pairs(lp.installed_packages()) do
			track_modules(package)
		end
	else
		track_modules(package)
	end
	return t
end

--the `package` arg is an optional filter.
function update_db_on_current_platform(package, mod)
	load_db()
	local platform = current_platform()
	local platform = current_platform()
	local data = get_tracking_data(package, mod)
	glue.update(glue.attr(db, platform), data)
end

--update the tracking database for one package or all packages,
--and for one platform or all platforms, by uploading and calling
--get_tracking_data() on a luapower RPC server running on the right platform.
--for the current platform, if allowed, and there's no server configured
--for it, do the tracking here, in-process.
--args `package` and `platform0` are optional filters.
function update_db(package, platform0, mod)
	load_db()
	local threads_started
	for platform in pairs(supported_platforms) do
		if not platform0 or platform == platform0 then --apply platform0 filter
			if platform == current_platform()
				and not servers[platforms] --servers are preferred
				and allow_update_db_locally --allowed updating natively
			then
				update_db_on_current_platform(package, mod)
			elseif servers[platform] then
				local loop = require'socketloop'
				loop.newthread(function()
					local lp, err = connect(platform)
					if lp then
						local data = lp.exec(get_tracking_data, package)
						lp.close()
						glue.update(glue.attr(db, platform), data)
					else
						print(platform..': '..err)
					end
				end)
				threads_started = true
			end
		end
	end
	if threads_started then
		local loop = require'socketloop'
		loop.start(1)
	end
end

function track_module_platform(mod, package, platform)
	platform = check_platform(platform)
	if not platform then return {} end
	package = package or module_package(mod)
	load_db()
	if package then
		if auto_update_db and not (
				db[platform]
				and db[platform][package]
				and db[platform][package][mod]
			)
		then
			update_db(package, platform, mod)
		end
	end
	return db[platform]
		and db[platform][package]
		and db[platform][package][mod] or {}
end

function server_status(platform0)
	local loop = require'socketloop'
	local t = {}
	for platform in glue.sortedpairs(servers) do
		if not platform0 or platform == platform0 then
			loop.newthread(function()
				local lp, err = connect(platform)
				if lp then
					local os, arch = lp.osarch()
					t[platform] = {os = os, arch = arch}
	 				lp.close()
	 			else
	 				t[platform] = {err = err}
	 			end
			end)
		end
	end
	loop.start(1)
	return t
end

--module tracking breakdown
------------------------------------------------------------------------------

local empty = {}

--list of modules required when the target module is loaded.
function module_requires_loadtime(mod, package, platform)
	return track_module_platform(mod, package, platform).mdeps or empty
end

--list of modules that the user needs to load before loading the target module.
function module_environment(mod, package, platform)
	local env = track_module_platform(mod, package, platform).env
	local t = {}
	if env then
		for m in env:gmatch'[^%s]+' do
			t[m] = true
		end
	end
	return t
end

--return the module runtime.
function module_runtime(mod, package, platform)
	return {[track_module_platform(mod, package, platform).runtime or 'luajit'] = true}
end

--if loading the module resulted in an error, return that error.
function module_load_error(mod, package, platform)
	return track_module_platform(mod, package, platform).loaderr
end

--list of a module's supported platforms, which is a subset of it's package's
--supported platforms. a module can signal that it doesn't support a specific
--platform by raising an error containing 'platform not ' or 'arch not '.
module_platforms = memoize_mod_package('module_platforms', function(mod, package)
	package = package or module_package(mod)
	local t = {}
	local platforms = platforms(package)
	if not next(platforms) then --package doesn't specify, so check all.
		platforms = supported_platforms
	end
	for platform in pairs(platforms) do
		local err = module_load_error(mod, package, platform)
		if not err or not (
			   err:find'platform not '
			or err:find'arch not '
		) then
			t[platform] = true
		end
	end
	return t
end)

--list of modules ffi.load()'ed when the module was loaded.
function module_requires_loadtime_ffi(mod, package, platform)
	return track_module_platform(mod, package, platform).ffi_deps or empty
end

--the glue.autoload() table attached to the target module, if any.
function module_autoloads(mod, package, platform)
	return track_module_platform(mod, package, platform).autoloads or empty
end

--list of modules possibly required at runtime (detected through parsing).
module_requires_runtime = memoize('module_requires_runtime', function(mod, package, platform)
	local err = module_load_error(mod, package, platform)
	--if module doesn't load, hide its runtime deps.
	if err then return {} end
	return module_requires_runtime_parsed(mod)
end)

--list of auto-loaded modules on the target module.
module_autoloaded = memoize('module_autoloaded', function(mod, package, platform)
	local t = {}
	for _,mod in pairs(module_autoloads(mod, package, platform)) do
		t[mod] = true
	end
	return t
end)

--alltime means loadtime + runtime + autoloaded.
module_requires_alltime = memoize('module_requires_alltime', function(mod, package, platform)
	return glue.update({},
		module_requires_loadtime(mod, package, platform),
		module_autoloaded(mod, package, platform),
		module_requires_runtime(mod, package, platform))
end)


--indirect module dependencies
------------------------------------------------------------------------------

--given a dependency-getting function, get a module's dependencies
--recursively, as a table's keys.
local function module_requires_recursive_keys_for(deps_fname, deps_func)
	return memoize('module_requires_recursive_keys_for_'..deps_fname, function(mod, package, platform)
		local t = {}
		local function add_deps(mod, package, platform)
			for dep in pairs(deps_func(mod, package, platform)) do
				if not t[dep] then --prevent cycles
					t[dep] = true
					--we don't know the package of indirect deps.
					add_deps(dep, nil, platform)
				end
			end
		end
		add_deps(mod, package, platform)
		return t
	end)
end

--given a dependency-getting function, get a module's dependencies
--recursively, as a tree.
local function module_requires_recursive_tree_for(deps_fname, deps_func)
	return memoize('module_requires_recursive_tree_for_'..deps_fname, function(mod, package, platform)
		local function add_deps(pnode, package, platform)
			for dep in pairs(deps_func(pnode.name, package, plaform)) do
				local node = {name = dep}
				pnode.children = pnode.children or {}
				table.insert(pnode.children, node)
				add_deps(node, nil, platform)
			end
			return pnode
		end
		return add_deps({name = mod}, package, platform)
	end)
end

module_requires_loadtime_tree =
	module_requires_recursive_tree_for('module_requires_loadtime', module_requires_loadtime)
module_requires_loadtime_all  =
	module_requires_recursive_keys_for('module_requires_loadtime', module_requires_loadtime)
module_requires_alltime_all   =
	module_requires_recursive_keys_for('module_requires_alltime', module_requires_alltime)

--direct and indirect internal (i.e. same package) module deps of a module
module_requires_loadtime_int = memoize('module_requires_loadtime_int', function(mod, package, platform)
	package = package or module_package(mod)
	local internal = modules(package)
	return filter(module_requires_loadtime_all(mod, package, platform),
			function(m) return internal[m] end)
end)

--direct external module deps of a module and its internal deps
module_requires_loadtime_ext = memoize('module_requires_loadtime_ext', function(mod, package, platform)
	local t = {}
	package = package or module_package(mod)
	--direct deps of mod
	glue.update(t, module_requires_loadtime(mod, package, platform))
	--internal deps of mod
	for mod in pairs(module_requires_loadtime_int(mod, package, platform)) do
		--direct deps of internal deps of mod
		glue.update(t, module_requires_loadtime(mod, package, platform))
	end
	local internal = modules(package)
	return filter(t, function(mod) return not internal[mod] end)
end)


--indirect package dependencies
------------------------------------------------------------------------------

--direct and indirect binary dependencies of a package
bin_deps_all = memoize_opt_package('bin_deps_all', function(package, platform)
	local t = {}
	local function add_deps(package)
		for dep in pairs(bin_deps(package, platform)) do
			if not t[dep] then --skip cycles
				t[dep] = true
				add_deps(dep)
			end
		end
	end
	add_deps(package)
	return t
end)


--reverse module dependencies
------------------------------------------------------------------------------

--get the modules and packages that depend on a module,
--given a dependency-getting function.
local function module_required_for(deps_fname, deps_func, add_rev_bin_deps)
	return memoize('module_required_for_'..deps_fname, function(mod, package0, platform)
		local t = {}
		local pt = {}
		package0 = package0 or module_package(mod)
		for package in pairs(installed_packages()) do
			if package ~= package0 then --not of self
				for dmod in pairs(modules(package)) do
					if deps_func(dmod, package, platform)[mod] then
						t[dmod] = true
						pt[package] = true
					end
				end
			end
		end
		if add_rev_bin_deps then
			glue.update(pt, rev_bin_deps_all(package0, platform))
		end
		return t, pt
	end)
end

--all modules and packages that depend on a module, directly and indirectly.
module_required_loadtime     = module_required_for('module_requires_loadtime'    , module_requires_loadtime)
module_required_environment  = module_required_for('module_environment'          , module_environment)
module_required_alltime      = module_required_for('module_requires_alltime'     , module_requires_alltime)
module_required_loadtime_all = module_required_for('module_requires_loadtime_all', module_requires_loadtime_all)
module_required_alltime_all  = module_required_for('module_requires_alltime_all' , module_requires_alltime_all)

--given a package dependency-getting function, get packages that depend on a
--package.
local function package_required_for(deps_fname, deps_func)
	return memoize('package_required_for_'..deps_fname, function(package0, platform)
		local t = {}
		for package in pairs(installed_packages()) do
			if package ~= package0 then --not of self
				if deps_func(package, platform)[package0] then
					t[package] = true
				end
			end
		end
		return t
	end)
end


--reverse package dependencies
------------------------------------------------------------------------------

--which packages is a package a binary dependency of.
rev_bin_deps     = package_required_for('bin_deps'    , bin_deps)
rev_bin_deps_all = package_required_for('bin_deps_all', bin_deps_all)


--analytic info
------------------------------------------------------------------------------

--analytic info for a module
module_tags = memoize('module_tags', function(package, mod)
	local mod_path = modules(package)[mod]
	local t = {}
	t.lang =
		mod_path == true and 'built-in'
		or lua_module_name(tostring(mod_path)) and 'Lua'
		or dasl_module_name(tostring(mod_path)) and 'Lua/ASM'
		or c_module_name(tostring(mod_path)) and 'C'
		or terra_module_name(tostring(mod_path)) and 'Terra'
	t.demo_module = scripts(package)[mod..'_demo'] and mod..'_demo'
	t.test_module = scripts(package)[mod..'_test'] and mod..'_test'
	return t
end)

--analytic info for a package
package_type = memoize_package('package_type', function(package)
	local has_c = csrc_dir(package) and true or false
	local has_mod = next(modules(package)) and true or false
	local has_mod_c = false
	local has_ffi = false
	local has_bit = false
	local has_terra = false
	local has_ngx = false
	for mod in pairs(modules(package)) do
		local lang = module_tags(package, mod).lang
		if lang == 'C' then
			has_mod_c = mod
		elseif lang == 'Terra' then
			has_terra = true
		end
		for platform in pairs(module_platforms(mod, package)) do
			local t = module_requires_loadtime_all(mod, package, platform)
			if t.ffi then
				has_ffi = mod
			end
			if t.has_bit then
				has_bit = mod
			end
			local env = module_environment(mod, package, platform)
			if env.ngx then
				has_ngx = true
			end
		end
	end
	--disambiguate: package has both Lua/C and Lua+ffi modules.
	--decide the package type based on what the main module is, if any.
	if has_mod_c and has_ffi then
		if has_mod_c == package then
			has_ffi = false
		elseif has_ffi == package then
			has_mod_c = false
		end
	end
	assert(not has_mod_c or has_c) --Lua/C modules without source?
	return
		has_ngx and 'Resty'
		or has_ffi and (has_terra and 'Terra' or 'Lua+ffi')
		or has_mod and (has_mod_c and 'Lua/C' or (has_terra and 'Terra' or 'Lua'))
		or has_c and 'C' or 'other'
end)

local function key(key, t) return t and t[key] end

--author can be specified in the header of the main module file or in the .md file.
author = memoize_package('author', function(package)
	return
		key('author', doc_tags(package, package)) or
		key('author', module_header(package, package))
end)

--license can be specified in the header of the main module file
--or in the .md file, otherwise the WHAT-file license is assumed,
--and finally the default license is used as a fallback.
license = memoize_package('license', function(package)
	return
		key('license', doc_tags(package, package)) or
		key('license', what_tags(package)) or
		key('license', module_header(package, package)) or
		default_license
end)

--a module's tagline can be specified in the header of the module file
--or in the .md of the module.
module_tagline = memoize_package('module_tagline', function(package, mod)
	local s =
		   key('tagline', doc_tags(package, mod))
		or key('descr', module_header(package, mod))
	return s and s:gsub('^[%w]', string.upper):gsub('%.%s*$', '') or nil
end)

--pkg -> cat map
packages_cats = memoize('packages_cats', function()
	local t = {}
	for i,cat in ipairs(cats()) do
		for i,pkg in ipairs(cat.packages) do
			t[pkg.name] = cat.name
		end
	end
	return t
end)

function package_cat(pkg)
	return packages_cats()[pkg]
end

--given a list of packages as a comma-separated string, return a possible
--build order that assures that all the dependencies are built first.
build_order = memoize('build_order', function(packages, platform)
	platform = check_platform(platform)
	if not platform then return {} end
	local function input_packages()
		if not packages then
			return glue.update({}, installed_packages())
		end
		local t = {}
		for pkg in glue.gsplit(packages, '%s*,%s*') do
			t[pkg] = true
		end
		return t
	end
	local function dep_maps()
		local t = {}
		local function add_pkg(pkg)
			if t[pkg] then return true end --already added
			glue.assert(known_packages()[pkg], 'unknown package "%s"', pkg)
			if not build_platforms(pkg)[platform] then
				return --not buildable
			end
			glue.assert(installed_packages()[pkg],
				'package not installed "%s"', pkg)
			local deps = bin_deps(pkg, platform)
			local dt = {}
			t[pkg] = dt
			for pkg in pairs(deps) do
				if add_pkg(pkg) then
					dt[pkg] = true
				end
			end
			return true --added
		end
		for pkg in pairs(input_packages()) do
			add_pkg(pkg)
		end
		return t
	end
	--build packages with zero deps first, remove them from the dep lists
	--of all other packages and from the list of packages to build,
	--and repeat, until there are no more packages.
	local t = dep_maps()
	local dt = {}
	while next(t) do
		local guard = true
		for pkg, deps in glue.sortedpairs(t) do --stabilize the list
			if not next(deps) then
				guard = false
				table.insert(dt, pkg) --build it
				t[pkg] = nil --remove it from the to-build table
				--remove it from all dep lists
				for _, deps in pairs(t) do
					deps[pkg] = nil
				end
			end
		end
		if guard then
			dt.circular_deps = t --circular dependencies found
			break
		end
	end
	return dt
end)

build_circular_deps = function(...)
	return build_order(...).circular_deps
end

--consistency checks
--============================================================================

--check for the same doc in a different path.
--since all docs share the same namespace on the website, this is not allowed.
duplicate_docs = memoize('duplicate_docs', function()
	local dt = {} --{doc = package}
	local dupes = {}
	for package in pairs(installed_packages()) do
		for doc, path in pairs(docs(package)) do
			if dt[doc] then
				dupes[doc..' in '..package..' and '..dt[doc]] = true
			end
		end
	end
	return dupes
end)

--check for undocumented packages
undocumented_package = memoize_opt_package('undocumented_package', function(package)
	local t = {}
	local docs = docs(package)
	if not docs[package] then
		t[package] = true
	end
	return t
end)

--module load errors for each module of a package for one platform.
load_errors = memoize_opt_package('load_errors', function(package, platform)
	local errs = {}
	local platform = check_platform(platform)
	if not platform then return errs end
	for mod in pairs(modules(package)) do
		if module_platforms(mod, package)[platform] then
			local err = module_load_error(mod, package, platform)
			errs[mod] = err
		end
	end
	return errs
end)


--updating the mgit deps files
--============================================================================

--given {place1 = {item1 = val1, ...}, ...}, extract items that are
--found in all places into the place indicated by all_key.
local function extract_common_keys(maps, all_key)
	--count occurences for each item
	local maxn = glue.count(maps)
	--if less than two places to group, don't group
	if maxn < 2 then return maps end
	local nt = {} --{item = n}
	local tt = {} --{item = val}
	for place, items in pairs(maps) do
		for item, val in pairs(items) do
			nt[item] = (nt[item] or 0) + 1
			--val of 'all' is the val of the first item.
			tt[item] = tt[item] or val
		end
	end
	--extract items found in all places
	local all = {}
	for item, n in pairs(nt) do
		if n == maxn then
			all[item] = tt[item]
		end
	end
	--add items not found in all places, to their original places
	local t = {[all_key] = next(all) and all}
	for place, items in pairs(maps) do
		for item, val in pairs(items) do
			if all[item] == nil then
				glue.attr(t, place)[item] = val
			end
		end
	end
	return t
end

--same as above, but use an "all-or-nothing strategy" of extraction
local function extract_common_keys_aot(maps, all_key)
	--count occurences for each item
	local maxn = glue.count(maps)
	--if less than two places to group, don't group
	if maxn < 2 then return maps end
	local nt = {} --{item = n}
	local tt = {} --{item = val}
	for place, items in pairs(maps) do
		for item, val in pairs(items) do
			nt[item] = (nt[item] or 0) + 1
			--val of 'all' is the val of the first item.
			tt[item] = tt[item] or val
		end
	end
	--check to see if all items were extracted
	local all_extracted = true
	for item, n in pairs(nt) do
		if n < maxn then
			all_extracted = false
		end
	end
	return all_extracted and {[all_key] = tt} or maps
end

--given {platform1 = {item1 = val1, ...}, ...}, group items that are
--common to the same OS into OS keys, and all-around common items
--into the all_key key, if given.
local function platform_maps(maps, all_key, aot)
	local extract = aot and extract_common_keys_aot or extract_common_keys
	--extract common items across all places, if all_key given
	maps = all_key and extract(maps, all_key) or glue.update({}, maps)
	--combine platforms per OS
	for _,os in ipairs(supported_os_list) do
		local t = {}
		for platform in pairs(supported_os_platforms[os]) do
			t[platform] = maps[platform]
			maps[platform] = nil
		end
		glue.update(maps, extract(t, os))
	end
	return maps
end

local function packages_of(dep_func, mod, pkg, platform)
	mod = mod or modules(pkg)
	--many modules
	if type(mod) == 'table' then
		local t = {}
		for mod in pairs(mod) do
			glue.update(t, packages_of(dep_func, mod, pkg, platform))
		end
		return t
	end
	--single module
	local t = {}
	for mod in pairs(dep_func(mod, pkg, platform)) do
		local dpkg = module_package(mod)
		if dpkg and dpkg ~= pkg then --exclude self
			t[dpkg] = true
		end
	end
	return t
end

function update_mgit_deps(package)
	if not package then
		for package in pairs(installed_packages()) do
			update_mgit_deps(package)
		end
		return
	else
		--collect packages of direct external module deps
		local pkgs = {}
		local has_deps
		for platform in pairs(supported_platforms) do
			local pext = packages_of(
				module_requires_loadtime_ext,
				nil, package, platform)
			glue.update(pext, bin_deps(package, platform))
			has_deps = has_deps or next(pext)
			pkgs[platform] = pext
		end
		if not has_deps then
			return
		end
		local pkgs = platform_maps(pkgs, '_all')

		--generate the .dep file
		local t = {}
		local function out(s)
			t[#t+1] = s
		end
		for platform, pkgs in glue.sortedpairs(pkgs) do
			if next(pkgs) then
				if platform ~= '_all' then
					out(platform)
					out': '
				end
				local first = true
				for pkg in glue.sortedpairs(pkgs) do
					if first then
						first = false
					else
						out' '
					end
					out(pkg)
				end
				out'\n'
			end
		end
		local depfile = powerpath(mgitpath(package)..'.deps')
		local s = table.concat(t)
		glue.writefile(depfile, s, nil, depfile..'.tmp')
	end
end


--use luapower remotely via a RPC server
--============================================================================

local rpc = require'luapower_rpc'

function connect(ip, port, connect)
	local srv = servers[ip] --ip is platform here
	if srv then
		ip, port = unpack(srv)
	end
	assert(ip, 'invalid ip or platform')
	local rpc, err = rpc.connect(ip, port, connect)
	if not rpc then return nil, err end
	rpc.exec(function()
			local luapower = require'luapower'
			function exec(func, ...)
				return luapower[func](...)
			end
		end)
	local lp = {}
	function lp.close()
		if not rpc then return end --already closed
		rpc.close()
		rpc = nil
	end
	function lp.stop()
		rpc.stop()
		rpc = nil
	end
	function lp.restart()
		rpc.restart()
		rpc = nil
	end
	setmetatable(lp, {__index = function(t, k)
			return function(...)
				return rpc.exec('exec', k, ...)
			end
		end})
	return lp
end

function osarch() --for RPC use
	return ffi.os, ffi.arch
end

function exec(func, ...) --for RPC use
	return func(...)
end

--these stubs are implemented only in RPC luapower namespaces.
function restart() error'not connected' end
function stop() error'not connected' end

return luapower
