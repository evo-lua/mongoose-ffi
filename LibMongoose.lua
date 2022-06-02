local mongoose = _G.import("./mongoose.lua")
local bindings = mongoose.bindings

local ffi = require("ffi")

local function test()


	local function onMongooseEventCallbackFunction(connection, eventID, eventData, userData)
		print("OnMongooseEvent", tonumber(connection.id), tonumber(eventID))
	end


	local mongooseEventManager = ffi.new("struct mg_mgr");
	mongoose.bindings.mg_mgr_init(mongooseEventManager);
	mongoose.bindings.mg_http_listen(mongooseEventManager, "0.0.0.0:8000", onMongooseEventCallbackFunction, nil);
	while true do
		mongoose.bindings.mg_mgr_poll(mongooseEventManager, 1000);
	end

end

local HttpServer = {}

function HttpServer:Construct()
	local instance = {}

	local inheritanceMetatable = {
		__index = HttpServer
	}

	setmetatable(instance, inheritanceMetatable)

	instance.__className = "HttpServer"

	return instance
end

function HttpServer:IsListening()

end

function HttpServer:StartListening(port, host)
	port = port or 80
	host = host or "0.0.0.0"
end


local LibMongoose = {
	reusableMd5Context = ffi.new("mg_md5_ctx"),
	reusableMd5OutputBuffer = ffi.new("unsigned char [?]", 16)
}

function LibMongoose:CreateHttpServer()

	local server = HttpServer:Construct()

	return server
end

function LibMongoose.CreateHttpsServer() end
function LibMongoose.CreateWebSocketServer() end
function LibMongoose.CreateSecureWebSocketServer() end
function LibMongoose.CreateHttpServer() end

-- calculate the size of 'output' buffer required for a 'input' buffer of length x during Base64 encoding operation
-- #define B64ENCODE_OUT_SAFESIZE(x) ((((x) + 3 - 1)/3) * 4 + 1)

local math_ceil = math.ceil
local function B64ENCODE_OUT_SAFESIZE(x)
	return math_ceil((((x) + 3 - 1)/3) * 4 + 1)
end

-- calculate the size of 'output' buffer required for a 'input' buffer of length x during Base64 decoding operation
local function B64DECODE_OUT_SAFESIZE(x)
	return math_ceil(((x)*3)/4)
end

function LibMongoose.EncodeBase64(luaString)

	if type(luaString) ~= "string" then return end

	local numBytesRequired = B64ENCODE_OUT_SAFESIZE(#luaString)
	local outputBuffer = ffi.new("char [?]", numBytesRequired)
	bindings.mg_base64_encode(luaString, #luaString, outputBuffer)

	return ffi.string(outputBuffer)
end

function LibMongoose.DecodeBase64(base64EncodedString)
	if type(base64EncodedString) ~= "string" then return end

	local numBytesRequired = B64DECODE_OUT_SAFESIZE(#base64EncodedString)
	local outputBuffer = ffi.new("char [?]", numBytesRequired)
	bindings.mg_base64_decode(base64EncodedString, #base64EncodedString, outputBuffer)

	return ffi.string(outputBuffer)
end

local format = format
local table_concat = table.concat

function LibMongoose.MD5(luaString)
	if type(luaString) ~= "string" then return end

	-- Reset context without allocating more memory
	bindings.mg_md5_init(LibMongoose.reusableMd5Context)
	bindings.mg_md5_update(LibMongoose.reusableMd5Context, luaString, #luaString)
	bindings.mg_md5_final(LibMongoose.reusableMd5Context, LibMongoose.reusableMd5OutputBuffer)

	-- This seems too complicated; does Lua not offer a better way (that doesn't require extra steps)?
	local result = LibMongoose.reusableMd5OutputBuffer
	local hexBytes = {}
	for index = 0, 15, 1 do
		local character = result[index]
		hexBytes[#hexBytes+1] = format("%02x", character)
	end
	return table_concat(hexBytes, "")
end

function LibMongoose.EncodeSHA1() end
function LibMongoose.DecodeSHA1() end

function LibMongoose.CRC32(luaString)
	if type(luaString) ~= "string" then return end

	local checksum = bindings.mg_crc32(0, luaString, #luaString)
	return checksum
end

return LibMongoose