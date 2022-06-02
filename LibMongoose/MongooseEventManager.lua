
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

local uv = require("uv")

function MongooseEventManager:StartListening(port, host)

	-- TODO tests for using defaults, tests for passing non number args
	port = port or self.DEFAULT_PORT
	host = host or self.DEFAULT_HOST_NAME

	-- todo missing args, concat errors
	self.url = self.protocol .. "://" .. host .. ":" .. port

	-- To pass self (C doesn't do that obviously)
	local function onEventWrapper(...)
		self:OnEvent(...)
	end
	mongoose.bindings.mg_listen(self.mg_mgr, self.url, onEventWrapper, nil);
	self.isListening = true

	local prepare = uv.new_idle()
	-- local pollingTask =
	prepare:start(function()
	  print("Before I/O polling")
	  mongoose.bindings.mg_mgr_poll(self.mg_mgr, 1000);
	end)

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

function MongooseEventManager:OnEvent(connection, eventID, eventData, userData)
	local eventName = mongoose.events[eventID]
	EVENT("Connection #" .. tonumber(connection.id) .. ": " .. eventName)
	print("OnEvent", eventName, tonumber(connection.id), tonumber(eventID))

	if eventName == "MG_EV_ERROR" then self:OnError(connection, eventData) end
end

function MongooseEventManager:OnError(connection, errorMessage)

	print(errorMessage)
	EVENT("OnError for connection #"  .. tonumber(connection.id))
	-- EVENT("OnError for connection #"  .. tonumber(connection.id) .. " (Message: " .. ffi.string(errorMessage) .. ")")
end


return MongooseEventManager