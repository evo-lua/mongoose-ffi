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

function LibMongoose.EncodeBase64() end
function LibMongoose.DecodeBase64() end


local function hexStringToNumber(hexString)

end

local format = format

function LibMongoose.MD5(luaString)
	if type(luaString) ~= "string" then return end

	-- Reset context without allocating more memory
	bindings.mg_md5_init(LibMongoose.reusableMd5Context)

	bindings.mg_md5_update(LibMongoose.reusableMd5Context, luaString, #luaString)
	bindings.mg_md5_final(LibMongoose.reusableMd5Context, LibMongoose.reusableMd5OutputBuffer)
	local result = LibMongoose.reusableMd5OutputBuffer
	local hexBytes = {}
	for index = 0, 15, 1 do
		local character = result[index]
		hexBytes[#hexBytes+1] = format("%02x", character)
	end
	return table.concat(hexBytes, "")
end

function LibMongoose.EncodeSHA1() end
function LibMongoose.DecodeSHA1() end

function LibMongoose.CRC32(luaString)
	if type(luaString) ~= "string" then return end

	local checksum = bindings.mg_crc32(0, luaString, #luaString)
	return checksum
end

return LibMongoose