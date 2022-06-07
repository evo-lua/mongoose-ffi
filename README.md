# About

[Mongoose](https://mongoose.ws/) is an embedded WebServer library written in C. This repository contains [LuaJIT FFI](https://luajit.org/ext_ffi.html) bindings for [mongoose's API](https://mongoose.ws/documentation/#api-reference).

## Features

The entirety of mongoose's public API should be exported, allowing you to

* Create TCP and UDP socket connections
* Create HTTP/S servers and clients
* Create WebSocket servers and clients
* Compute MD5, SHA1, CRC32, and Base64

Anything mongoose can do, these bindings expose (unless I've missed something).

## Status

This was an experiment, but it works well enough for what it is. The glue code is minimal, so maintaining it shouldn't be a problem.

## Usage

Simply import ``mongoose.lua`` in your application, then call the ``mongoose.bindings.*`` functions that directly map to mongoose's C API.

## API

The exported API is defined in ``mongoose.def`` (MSVC exports). If something's not there I probably missed it, so please open an issue.

## Platforms

The bindings have been tested on Windows, with an example ``mongoose.dll`` being created as part of the release process.

## Prerequisites

Since mongoose is a simple C library, you must build a shared library. See ``make.cmd`` for a Windows example (run in VS developer prompt).  Other platforms should also work, but you'll have to build mongoose first, e.g., using ``gcc`` (scripts not included, but the process is painless).

The example is built with OpenSSL and a ``prepare-dependencies.cmd`` script shows how to download the dependencies. This takes a long time.

## Examples

```lua
local mongoose = require("mongoose.lua")

local bindings = mongoose.bindings -- Exported C API functions
local events = mongoose.events -- Reverse lookup table mapping mongoose event IDs to human-readable names
local cdefs = mongoose.cdefs -- The C definitions used to load the library via LuaJIT FFI
```

Experimental and unfinished high-level Lua API examples can be found in the [9-lua-api-common](https://github.com/evo-lua/mongoose-ffi/blob/9-lua-api-common/LibMongoose.lua) branch.

This includes some basic tests for all the utility functions, and TCP/HTTP/WebSocket echo servers. It will only work when using the evo runtime, but you can still see how the low-level bindings are used. I don't currently plan on finishing them, but you're free to take what you need.

## Licensing

Mongoose is licensed under the GNU Public License, unless you purchased a commercial license. The bindings' glue code is licensed under the same terms, though I really don't care what you do with them as long as you adhere to mongoose's licensing terms.
