local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/computing-crc32-checksums.lua",
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite