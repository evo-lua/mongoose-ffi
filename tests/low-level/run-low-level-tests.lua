local testSuite = import("./test-c-bindings.lua")
assert(testSuite:Run(), "Should expose mongoose's low-level API directly")
