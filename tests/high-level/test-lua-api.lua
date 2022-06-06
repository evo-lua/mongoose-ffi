local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/computing-crc32-checksums.lua",
	"./scenarios/computing-md5-checksums.lua",
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite