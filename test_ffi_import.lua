local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")

local WINDOWS_SHARED_LIBRARY_EXTENSION = "dll"
local UNIX_SHARED_LIBRARY_EXTENSION = "so"
local expectedFileExtension = isWindows and WINDOWS_SHARED_LIBRARY_EXTENSION or UNIX_SHARED_LIBRARY_EXTENSION
local bindings = ffi.load("mongoose_ffi" .. "." .. expectedFileExtension)


local mongoose = {
	cdefs = [[
		void Mongoose_CreateHttpServer();
	]]
}

ffi.cdef(mongoose.cdefs)

bindings.Mongoose_CreateHttpServer()
