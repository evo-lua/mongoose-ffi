local testSuite = import("./test-bindings-api-is-exported.lua")
assert(testSuite:Run(), "Should expose mongoose's low-level API directly")