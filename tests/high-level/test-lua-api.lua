local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	-- "./scenarios/accessing-c-functions.lua",
	-- "./scenarios/accessing-event-names.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite