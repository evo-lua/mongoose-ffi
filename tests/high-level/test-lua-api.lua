local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/computing-crc32-checksums.lua",
	"./scenarios/computing-md5-checksums.lua",
	"./scenarios/computing-sha1-checksums.lua",
	"./scenarios/encoding-base64-strings.lua",
	"./scenarios/decoding-base64-strings.lua",
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite