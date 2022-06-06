local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite