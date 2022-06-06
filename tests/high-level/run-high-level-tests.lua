local testSuite = import("./test-lua-api.lua")
assert(testSuite:Run(), "Should provide a high-level Lua API for mongoose's functionality")