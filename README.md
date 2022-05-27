# mongoose-ffi

Lua bindings for the mongoose embedded web server, compatible with LuaJIT's foreign function interface (FFI)

## Goals

Enable the creation of high-quality, battle-tested HTTP and WebSocket servers programmed via a convenient, high-level Lua API

## Features

The bindings currently expose only some of the functionality that mongoose provides:

* HTTP server
* WebSocket server

Everything else may require some glue code; I simply haven't had a need for it and so it's not yet implemened.

## Requirements

LuaJIT FFI, Win, Unix officially supported. Everything else should also work, but I can't test it on my machine.

## Security

I can make no promises here, though the glue code is minimal and hopefully doesn't introduce security vulnerabilities. Bring your own security experts to be sure.

## Performance

There's likely some overhead for using mongoose from Lua, even with LuaJIT. I've no benchmarks to offer currently, however.

## How to: Create HTTP Server

### Creating Event Managers

### Opening an HTTP Server

### Upgrading HTTP to WebSocket Connections

### Polling

### Event Handling

### Manual Polling

## How to: Create WebSocket Server

TODO

## How to: Create TCP Server

TODO

## How to: Create UDP Server

TODO

## How to: Build mongoose.dll on Windows

0. Install nasm perl etc following the openssl docs
1. Clone OpenSSL with git clone --recursive flag
2. Configure by following their instructions; ; IMPORTANT: you MUST pass the ``no-shared`` flag during the configure step to generate static libraries that can be used to generate a standalone mongoose.dll to be loaded from Lua
3. build for your desired architecture using vs dev shell
4. copy libcrypto.lib and libssl.lib in the root folder of mongoose-ffi
5. run make.cmd, hopefully it should work

The final ``mongoose.dll`` should have the following properties:

* Filze size about 4.2KB on Windows 10 (x64)
* Embeds all the SSL functions, so that no external openssl DLL will be required
* Exports all the mongoose functionality (API from their website/``mongoose.def``), can use ``peview`` to verify
* Can be loaded via ``ffi.load`` without any other dependencies

## How to: Integrate with libuv's Event Loop

LibUV via luv, as used in the luvit and evo runtimes. Still requires polling

## Licensing

mongoose license, GPL or commercial. Glue code is whatever

## Exported API

These bindings consist of multiple abstraction layers so that you can choose whichever you prefer:

* ``mongoose.lua`` are (very thin) Lua bindings mapping LuaJIT ``cdata`` and C APIs to Lua functions of the same name
* ``LibMongoose.lua`` uses these bindings to provide a Lua-only convenience layer, which may or may not incur some overhead

### Low-Level Bindings: mongoose.lua

The low-level bindings export a table with the following fields:

* ``mongoose.bindings`` exports the low-level C API, without changes or sanity checks of any kind (expect ``SEGFAULT`` when misused)
* ``mongoose.events`` exports a lookup table for mapping the low-level (integer) event type IDs to a human-readable string for the type
* ``mongoose.cdefs`` exports the C definitions as a ffi-loadable string, which is automatically loaded by the bindings

They expect a ``mongoose.dll`` (Windows), ``mongoose.so`` (Linux), or ``mongoose.dylib`` file to be present in the same folder, and will attempt to load it via ``ffi.load()``.

### High-Level API: LibMongoose.lua

This module exports a somewhat-abstracted API for accessing some of the core functionality that ``mongoose`` provides:

* HTTP Server
* WebSocket Server
* TLS/SSL encryption
* Base64, CRC32, MD5, SHA1

This obviously doesn't cover the entirety of what ``mongoose`` can do; I've simply added the APIs that I found most useful. If you need more than that, you can use the low-level bindings in ``mongoose.lua`` to implement it yourself, then please send a PR afterwards :)

## Backround Information

This section explains how the interactions between mongoose and the FFI bindings work conceptually.

### High-Level Overview

The general approach to working with mongoose is as follows:

1. Create mongoose event manager
2. Start listening for HTTP requests
3. Poll connections for updates
4. Handle the generated events

Even though this procedure involves switching between C and Lua, these bindings make all of mongoose's events available to Lua scripts.

### Control Flow

Since callbacks from C to Lua are fairly involved and also expensive, none are performed. It'll be your responsibility to keep polling for updates and handle the events that mongoose creates. This is accomplished by calling into the binding's glue code from the Lua side, which gives you typical Lua data types representing each event to work with in your application. C callbacks will run "behind the scenes" whenever you poll mongoose, storing events as userdata in a queue (for each connection), which the provided Lua API can access.

While this process is simple if your server doesn't need to do anything else, the bindings also allow for more complex use cases such as integrating the polling updates into a libuv-controlled event loop. The only change in this scenario is that you must interleave libuv's update step with mongoose's, for example by scheduling an "idle timer" that polls mongoose and subsequently sleeps before running the next libuv update.
