local MongooseEventManager = import("./LibMongoose/MongooseEventManager.lua")

local Socket = import("./LibMongoose/Socket.lua")
local HttpClient = import("./LibMongoose/HttpClient.lua")
local HttpServer = import("./LibMongoose/HttpServer.lua")
local WebSocketServer = import("./LibMongoose/WebSocketServer.lua")
local HttpRequest = import("./LibMongoose/HttpRequest.lua")

local mongoose = import("./mongoose.lua")
local bindings = mongoose.bindings

local ffi = require("ffi")

local LibMongoose = {
	reusableMd5Context = ffi.new("mg_md5_ctx"),
	reusableSha1Context = ffi.new("mg_sha1_ctx"),
	reusableMd5OutputBuffer = ffi.new("unsigned char [?]", 16),
	reusableSha1OutputBuffer = ffi.new("unsigned char [?]", 20)
}

function LibMongoose:CreateHttpClient()
	return HttpClient:Construct()
end

function LibMongoose:CreateSocket()
	return Socket:Construct()
end

function LibMongoose:CreateWebSocketServer()
	return WebSocketServer:Construct()
end

function LibMongoose:CreateHttpServer()
	local server = HttpServer:Construct()
	return server
end

-- function LibMongoose.CreateHttpsServer() end
-- function LibMongoose.CreateSecureWebSocketServer() end
-- function LibMongoose.CreateTcpServer()
-- 	local server = Socket:Construct()
-- 	return server
-- end

-- calculate the size of 'output' buffer required for a 'input' buffer of length x during Base64 encoding operation
local math_ceil = math.ceil
local function B64ENCODE_OUT_SAFESIZE(x)
	return math_ceil((((x) + 3 - 1)/3) * 4 + 1)
end

-- calculate the size of 'output' buffer required for a 'input' buffer of length x during Base64 decoding operation
local function B64DECODE_OUT_SAFESIZE(x)
	return math_ceil(((x)*3)/4)
end

local format = format
local table_concat = table.concat
local function CharBufferToHexString(charBuffer, numCharacters)
	local hexBytes = {}
	for index = 0, numCharacters - 1, 1 do
		local character = charBuffer[index]
		hexBytes[#hexBytes+1] = format("%02x", character)
	end
	return table_concat(hexBytes, "")
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

function LibMongoose.MD5(luaString)
	if type(luaString) ~= "string" then return end

	-- Reset context without allocating more memory
	bindings.mg_md5_init(LibMongoose.reusableMd5Context)
	bindings.mg_md5_update(LibMongoose.reusableMd5Context, luaString, #luaString)
	bindings.mg_md5_final(LibMongoose.reusableMd5Context, LibMongoose.reusableMd5OutputBuffer)

	-- This seems too complicated; does Lua not offer a better way (that doesn't require extra steps)?
	local result = LibMongoose.reusableMd5OutputBuffer

	return CharBufferToHexString(result, 16)
end

function LibMongoose.SHA1(luaString)
	if type(luaString) ~= "string" then return end

	-- Reset context without allocating more memory
	bindings.mg_sha1_init(LibMongoose.reusableSha1Context)
	bindings.mg_sha1_update(LibMongoose.reusableSha1Context, luaString, #luaString)
	bindings.mg_sha1_final(LibMongoose.reusableSha1OutputBuffer, LibMongoose.reusableSha1Context)

	local result = LibMongoose.reusableSha1OutputBuffer

	return CharBufferToHexString(result, 20)
end

function LibMongoose.CRC32(luaString)
	if type(luaString) ~= "string" then return end

	local checksum = bindings.mg_crc32(0, luaString, #luaString)
	return checksum
end

return LibMongoose