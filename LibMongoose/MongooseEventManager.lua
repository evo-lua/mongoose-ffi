
local ffi = require("ffi")
local mongoose = import("../mongoose.lua")

------ Mongoose Event Manager (prototype)
local MongooseEventManager = {
	DEFAULT_PORT = 80,
	DEFAULT_HOST_NAME = "localhost",
}

function MongooseEventManager:Construct()
	local instance = {}

	local inheritanceMetatable = {
		__index = MongooseEventManager
	}

	local mongooseEventManager = ffi.new("struct mg_mgr");
	mongoose.bindings.mg_mgr_init(mongooseEventManager);
	instance.mg_mgr = mongooseEventManager

	-- Has to be set by the individual server APIs
	instance.protocol = "invalid" -- For easier debugging
	instance.url = ""
	instance.isListening = false

	setmetatable(instance, inheritanceMetatable)

	return instance
end

function MongooseEventManager:StartListening(port, host)

	-- TODO tests for using defaults, tests for passing non number args
	port = port or self.DEFAULT_PORT
	host = host or self.DEFAULT_HOST_NAME

	-- todo missing args, concat errors
	self.url = self.protocol .. "://" .. host .. ":" .. port
	self.isListening = true

	return true
end

-- function MongooseEventManager:StopListening()
-- 	self.isListening = false
-- 	return true
-- end

function MongooseEventManager:IsListening()
	return self.isListening
end

function MongooseEventManager:GetURL()
	return self.url
end

return MongooseEventManager