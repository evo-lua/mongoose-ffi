local testSuite = import("./test-bindings-api-is-exported.lua")
assert(testSuite:Run(), "Should expose mongoose's low-level API directly")




-- function TestSuite:TestEventConstantsAreExported()

-- 	for eventTypeID, eventName in ipairs(mongoose.events) do
-- 		assert(type(eventName) == "string", "Should export event name for event of type " .. eventTypeID)
-- 	end

-- 	local EXPECTED_NUM_EVENTS = 19 -- I guess it's not changing anytime soon
-- 	assert(#mongoose.events == EXPECTED_NUM_EVENTS,
-- 	"Should export " .. EXPECTED_NUM_EVENTS .. " events (actual: " .. #mongoose.events.. ")")

-- 	print("OK\tEvent constants are exported")

-- end


-- self:TestLowLevelBindings()

-- function TestSuite:TestLowLevelApiSurface()

-- 	local EXPECTED_NUM_FUNCTIONS = 109
-- 	local numFunctionsExported = 0

-- 	for _, exportedFunctionName in ipairs(self.exportedApiSurface) do
-- 		assert(type(mongoose.bindings[exportedFunctionName]) == "cdata", "Should export function " .. exportedFunctionName)
-- 			numFunctionsExported = numFunctionsExported + 1
-- 		end

-- 		assert(numFunctionsExported == EXPECTED_NUM_FUNCTIONS,
-- 		"Should export " .. EXPECTED_NUM_FUNCTIONS .. " functions (actual: " .. numFunctionsExported.. ")")

-- 		print("OK\tLow-level API functions are exported")
-- end