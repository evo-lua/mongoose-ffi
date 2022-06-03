
local ffi = require("ffi")
local mongoose = import("../mongoose.lua")

------ Mongoose Event Manager (prototype)
local MongooseEventManager = {
	DEFAULT_PORT = 80,
	DEFAULT_HOST_NAME = "localhost",
}

function MongooseEventManager:Construct(protocol)
	local instance = {}

	local inheritanceMetatable = {
		__index = MongooseEventManager
	}

	local mongooseEventManager = ffi.new("struct mg_mgr");
	mongoose.bindings.mg_mgr_init(mongooseEventManager);
	instance.mg_mgr = mongooseEventManager

	-- Has to be set by the individual server APIs
	instance.protocol = protocol or "invalid" -- For easier debugging
	instance.url = ""
	instance.isListening = false

	instance.isEchoServer = false

	setmetatable(instance, inheritanceMetatable)

	return instance
end

local uv = require("uv")

function MongooseEventManager:EnableEchoServerMode()
	self.isEchoServer = true
end

function MongooseEventManager:DisableEchoServerMode()
	self.isEchoServer = false
end

function MongooseEventManager:IsEchoServer()
	return self.isEchoServer
end

function MongooseEventManager:StartListening(port, host)

	-- TODO tests for using defaults, tests for passing non number args
	port = port or self.DEFAULT_PORT
	host = host or self.DEFAULT_HOST_NAME

	-- todo missing args, concat errors
	self.url = self.protocol .. "://" .. host .. ":" .. port

	DEBUG("Started listening at URL: " .. self.url)

	-- To pass self (C doesn't do that obviously)
	local function onEventWrapper(...)
		self:OnEvent(...)
	end
	mongoose.bindings.mg_listen(self.mg_mgr, self.url, onEventWrapper, nil);
	self.isListening = true

	C_EventLoop.ScheduleAsyncTask(
		function()
			-- The timeout is handled by the event loop
			mongoose.bindings.mg_mgr_poll(self.mg_mgr, 1);
		end
	)

	-- local prepare = uv.new_idle()
	-- -- local pollingTask =
	-- prepare:start(function()
	-- --   print("Before I/O polling")
	--   mongoose.bindings.mg_mgr_poll(self.mg_mgr, self.pollingTimeout);
	-- end)

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

function MongooseEventManager:EchoLastReceivedMessage(connection)
	-- TODO use data arg
	-- mg_send(c, c->recv.buf, c->recv.len);     // Echo received data back
	-- mg_iobuf_del(&c->recv, 0, c->recv.len);   // And discard it
	mongoose.bindings.mg_send(connection, connection.recv.buf, connection.recv.len)
	mongoose.bindings.mg_iobuf_del(connection.recv, 0, connection.recv.len)
end

function MongooseEventManager:OnEvent(connection, eventID, eventData, userData)
	local eventName = mongoose.events[eventID]
	-- print("OnEvent", eventName, tonumber(connection.id), tonumber(eventID))

	if eventName == "MG_EV_ERROR" then self:OnError(connection, eventData) end
	if eventName == "MG_EV_OPEN" then self:OnConnectionCreated(connection) end
	if eventName == "MG_EV_POLL" then self:OnUpdate(connection, eventData) end
	-- MG_EV_POLL = whatever , milliseconds param?
	if eventName == "MG_EV_RESOLVE" then self:OnHostNameResolved(connection) end
	if eventName == "MG_EV_CONNECT" then self:OnConnectionEstablished(connection) end
	if eventName == "MG_EV_ACCEPT" then self:OnConnectionAccepted(connection) end
	-- MG_EV_READ,        // Data received from socket    struct mg_str *
	if eventName == "MG_EV_READ" then self:OnDataReceived(connection, eventData) end
	-- MG_EV_WRITE,       // Data written to socket       long *bytes_written
	if eventName == "MG_EV_WRITE" then self:OnDataWritten(connection, eventData) end
	if eventName == "MG_EV_CLOSE" then self:OnConnectionClosed(connection) end
	-- MG_EV_HTTP_MSG,    // HTTP request/response        struct mg_http_message *
	if eventName == "MG_EV_HTTP_MSG" then self:OnHttpMessageReceived(connection, eventData) end
	-- MG_EV_HTTP_CHUNK,  // HTTP chunk (partial msg)     struct mg_http_message *
	if eventName == "MG_EV_HTTP_CHUNK" then self:OnHttpChunkReceived(connection, eventData) end
	-- MG_EV_WS_OPEN,     // Websocket handshake done     struct mg_http_message *
	if eventName == "MG_EV_WS_OPEN" then self:OnWebSocketHandshakeCompleted(connection, eventData) end
	-- MG_EV_WS_MSG,      // Websocket msg, text or bin   struct mg_ws_message *
	if eventName == "MG_EV_WS_MSG" then self:OnWebSocketMessageReceived(connection, eventData) end
	-- MG_EV_WS_CTL,      // Websocket control msg        struct mg_ws_message *
	if eventName == "MG_EV_WS_CTL" then self:OnWebSocketControlFrameReceived(connection, eventData) end
	-- MG_EV_MQTT_CMD,    // MQTT low-level command       struct mg_mqtt_message *
	-- MG_EV_MQTT_MSG,    // MQTT PUBLISH received        struct mg_mqtt_message *
	-- MG_EV_MQTT_OPEN,   // MQTT CONNACK received        int *connack_status_code
	-- MG_EV_SNTP_TIME,   // SNTP time received           uint64_t *milliseconds
end

function MongooseEventManager:OnError(connection, error_message)

	EVENT("SOCKET_ERROR", "Connection #"  .. tonumber(connection.id))

	print(error_message)
	print(ffi.string(error_message))
	print(tostring(error_message))
end

function MongooseEventManager:OnUpdate(connection, milliseconds)
	-- milliseconds = ffi.cast("uint64_t", milliseconds)
	-- print(milliseconds)
	-- EVENT("SOCKET_CONNECTION_UPDATED", tonumber(connection.id), tonumber(milliseconds))
end

function MongooseEventManager:OnConnectionCreated(connection)
	EVENT("SOCKET_CONNECTION_CREATED", tonumber(connection.id))
end

function MongooseEventManager:OnHostNameResolved(connection)
	EVENT("SOCKET_HOST_NAME_RESOLVED", tonumber(connection.id))
end

function MongooseEventManager:OnConnectionEstablished(connection)
	EVENT("SOCKET_CONNECTION_ESTABLISHED", tonumber(connection.id))
end

function MongooseEventManager:OnConnectionAccepted(connection)
	EVENT("SOCKET_CONNECTION_ACCEPTED", tonumber(connection.id))
end

function MongooseEventManager:OnDataReceived(connection, mg_str)
	-- TODO str
	EVENT("SOCKET_DATA_RECEIVED", tonumber(connection.id))
end

function MongooseEventManager:OnDataWritten(connection, bytes_written)
	local dereferencedPointerValue = ffi.cast("long*", bytes_written)[0]
	local numBytesSent = tonumber(dereferencedPointerValue) - 1 -- Ignore null terminator since it's always present
	EVENT("SOCKET_DATA_WRITTEN", tonumber(connection.id), numBytesSent)
end

function MongooseEventManager:OnConnectionClosed(connection)
	EVENT("SOCKET_CONNECTION_CLOSED", tonumber(connection.id))
end

function MongooseEventManager:OnHttpMessageReceived(connection, mg_http_message)
	-- TODO parse msg, pass length in bytes
	EVENT("HTTP_MESSAGE_RECEIVED", tonumber(connection.id))
	-- todo request/response
end

function MongooseEventManager:OnHttpChunkReceived(connection, mg_http_message)
	EVENT("HTTP_CHUNK_RECEIVED", tonumber(connection.id))
end

function MongooseEventManager:OnWebSocketHandshakeCompleted(connection, mg_http_message)
	EVENT("WEBSOCKET_HANDSHAKE_COMPLETED", tonumber(connection.id))
end

function MongooseEventManager:OnWebSocketMessageReceived(connection, mg_ws_message)
	EVENT("WEBSOCKET_MESSAGE_RECEIVED", tonumber(connection.id))
end

function MongooseEventManager:OnWebSocketControlFrameReceived(connection, mg_ws_message)
	EVENT("WEBSOCKET_CONTROL_FRAME_RECEIVED", tonumber(connection.id))
end

return MongooseEventManager