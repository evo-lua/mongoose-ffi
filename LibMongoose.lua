local function test()

	local ffi = require("ffi")

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

local LibMongoose = {}

function LibMongoose:CreateHttpServer() end
function LibMongoose:CreateHttpsServer() end
function LibMongoose:CreateWebSocketServer() end
function LibMongoose:CreateSecureWebSocketServer() end
function LibMongoose:CreateHttpServer() end
function LibMongoose:EncodeBase64() end
function LibMongoose:DecodeBase64() end
function LibMongoose:EncodeMD5() end
function LibMongoose:DecodeMD5() end
function LibMongoose:EncodeSHA1() end
function LibMongoose:DecodeSHA1() end
function LibMongoose:ComputeChecksum() end

return LibMongoose