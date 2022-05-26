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

LuaJIT FFI, Win, Unix officially supported. Everything else should also work, but can't be tested

## Security

I can make no promises here, though the glue code is minimal and hopefully doesn't introduce security vulnerabilities.

## Performance

There's likely some overhead for using mongoose from Lua, even with LuaJIT.

In particular, a more advanced allocator for the event queues that are introduced to faciliate the C-Lua interactions could be worthwhile. Benchmarks would be useful to determine potential bottlenecks. Since I'm not primarily a C programmer, someone more experienced would need to take a look at possible optimizations.

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

## How to: Integrate with libuv's Event Loop

LibUV via luv, as used in the luvit and evo runtimes. Still requires polling

## Licensing

mongoose license, GPL or commercial. Glue code is whatever

## Backround Information

This section explains how the interactions between mongoose and the FFI bindings work conceptually.

## High-Level Overview

The general approach to working with mongoose is as follows:

1. Create mongoose event manager
2. Start listening for HTTP requests
3. Poll connections for updates
4. Handle the generated events

Even though this procedure involves switching between C and Lua, these bindings make all of mongoose's events available to Lua scripts.

### Control Flow

Since callbacks from C to Lua are fairly involved and also expensive, none are performed. It'll be your responsibility to keep polling for updates and handle the events that mongoose creates. This is accomplished by calling into the binding's glue code from the Lua side, which gives you typical Lua data types representing each event to work with in your application. C callbacks will run "behind the scenes" whenever you poll mongoose, storing events as userdata in a queue (for each connection), which the provided Lua API can access.

While this process is simple if your server doesn't need to do anything else, the bindings also allow for more complex use cases such as integrating the polling updates into a libuv-controlled event loop. The only change in this scenario is that you must interleave libuv's update step with mongoose's, for example by scheduling an "idle timer" that polls mongoose and subsequently sleeps before running the next libuv update.
