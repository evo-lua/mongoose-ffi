local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/computing-crc32-checksums.lua",
	"./scenarios/computing-md5-checksums.lua",
	"./scenarios/encoding-base64-strings.lua",
	-- "./scenarios/accessing-event-names.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite