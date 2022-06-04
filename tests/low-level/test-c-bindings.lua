local testSuite = TestSuite:Construct("Low-Level C Bindings")

local listOfScenarioFilesToLoad = {
    "./scenarios/accessing-c-functions.lua",
    "./scenarios/accessing-event-names.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite
