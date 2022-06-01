-- Requires evo runtime, because I'm lazy
local mongoose = _G.import("mongoose.lua")
local LibMongoose = _G.import("LibMongoose.lua")

local TestSuite = {
	highlevelApiSurface = {
		"CreateHttpServer",
		"CreateHttpsServer",
		"CreateWebSocketServer",
		"CreateSecureWebSocketServer",
		"CreateHttpServer",
		"EncodeBase64",
		"DecodeBase64",
		"EncodeMD5",
		"DecodeMD5",
		"EncodeSHA1",
		"DecodeSHA1",
		"ComputeChecksum",
	}
}

function TestSuite:Run()
	print("Running some basic sanity tests...\n")
	self:TestHighLevelAPI()

	print("All tests done!")
end

function TestSuite:TestHighLevelAPI()
	print("TEST\tLibMongoose.lua (high-level API)")

	self:TestHighLevelApiSurface()
	self:TestHttpServerCreation()

	print("OK\tLibMongoose.lua (high-level API)\n")
end

function TestSuite:TestHighLevelApiSurface()

	local EXPECTED_NUM_FUNCTIONS = 12
	local numFunctionsExported = 0

	for _, exportedFunctionName in ipairs(self.highlevelApiSurface) do
		assert(type(LibMongoose[exportedFunctionName]) == "function", "Should export function " .. exportedFunctionName)
			numFunctionsExported = numFunctionsExported + 1
		end

		assert(numFunctionsExported == EXPECTED_NUM_FUNCTIONS,
		"Should export " .. EXPECTED_NUM_FUNCTIONS .. " functions (actual: " .. numFunctionsExported.. ")")

		print("OK\tHigh-level API functions are exported")
end

function TestSuite:TestHttpServerCreation()
	local port = 1234
	local host = "0.0.0.0"

	local server = LibMongoose:CreateHttpServer()
	assert(not server.IsListening(), "Server should not be started automatically")
	server:StartListening(port, host)
	assert(server.IsListening(), "Server should be started manually")
end





TestSuite:Run()