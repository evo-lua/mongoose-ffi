local testSuite = TestSuite:Construct("High-Level Lua Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/computing-crc32-checksums.lua",
	"./scenarios/computing-md5-checksums.lua",
	"./scenarios/computing-sha1-checksums.lua",
	"./scenarios/encoding-base64-strings.lua",
	"./scenarios/decoding-base64-strings.lua",
	"./scenarios/tcp-server.lua",
	-- "./scenarios/tcp-client.lua",
	-- "./scenarios/udp-server.lua",
	-- "./scenarios/udp-client.lua",
	-- "./scenarios/http-server.lua",
	-- "./scenarios/http-client.lua",
	-- "./scenarios/https-server.lua",
	-- "./scenarios/https-client.lua",
	-- "./scenarios/ws-server.lua",
	-- "./scenarios/ws-client.lua",
	-- "./scenarios/wss-server.lua",
	-- "./scenarios/wss-client.lua",
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite