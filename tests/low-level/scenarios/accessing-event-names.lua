local EXPECTED_NUM_EVENTS = 19 -- I guess it's not changing anytime soon

local scenario = Scenario:Construct("Accessing C event names")

scenario:WHEN("I import the mongoose C bindings")
scenario:THEN("I should be able access all event names that mongoose provides")

function scenario:OnRun()
	local mongoose = import("../../mongoose.lua")
	self.events = mongoose.events
end

function scenario:OnEvaluate()

	for eventTypeID, eventName in ipairs(self.events) do
		assertEquals(type(eventName), "string", "Should export enum key for eventTypeID " .. eventTypeID)
	end

	assertEquals(#self.events, EXPECTED_NUM_EVENTS,
	"Should export " .. EXPECTED_NUM_EVENTS .. " event names")

	print("OK\tEvent constants are exported")

end

return scenario