local mongoose = import("../mongoose.lua")

-- Upvalues
local ffi = require("ffi")
local rawget = rawget

local Socket = {}

function Socket:Construct()
	local instance = {}

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			if Socket[v] ~= nil then
				return Socket[v]
			else
				return rawget(t, v)
			end
		end
	}

	local mongooseEventManager = ffi.new("struct mg_mgr");
	mongoose.bindings.mg_mgr_init(mongooseEventManager);
	instance.eventManager = mongooseEventManager

	-- There could be multiple, but let's conveniently ignore that for now
	instance.listeningConnection = nil
	instance.outgoingConnection = nil

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

-- function Socket:OnDataReceived(connection, mg_str)
-- 	if self.isEchoServer then self:EchoLastReceivedMessage(connection) end
-- end

function Socket:EchoLastReceivedMessage(connection)
	DEBUG("Echoing data from the RECV buffer")
	mongoose.bindings.mg_send(connection, connection.recv.buf, connection.recv.len)
	DEBUG("Clearing RECV buffer")
	mongoose.bindings.mg_iobuf_del(connection.recv, 0, connection.recv.len)
end

function Socket:SchedulePollingUpdates()
	-- Can't use the mongoose event loop, so instead we schedule an async polling task that libuv controls
	C_EventLoop.ScheduleAsyncTask(
		function()
			-- The timeout is handled by the event loop (configurable)
			mongoose.bindings.mg_mgr_poll(self.eventManager, 0);
		end
	)
end

function Socket:IsListening()
	-- Not initialized
	if type(self.listeningConnection) ~= "cdata" then return false end

	-- No call to mg_listen
	return (self.listeningConnection.is_listening == 1)
end

function Socket:IsUDP()
	if self:IsListening() then return (self.listeningConnection.is_udp == 1) end
	if self:IsConnected() then return (self.outgoingConnection.is_udp == 1) end

	return false
end

function Socket:IsTCP()
	-- The HTTP and WebSocket protocols also use TCP
	if self:IsListening() then return (self.listeningConnection.is_udp == 0) end
	if self:IsConnected() then return (self.outgoingConnection.is_udp == 0) end

	return false
end

function Socket:StartListening(url)

	if type(url) ~= "string" then
		ERROR("Usage: Socket.StartListening(self : Socket, url : string)")
		return
	end

	DEBUG("Starting to listen on " .. url)

	-- To pass self to the Lua event handler
	local function onEventWrapper(...)
		self:OnEvent(...)
	end
	self.listeningConnection = mongoose.bindings.mg_listen(self.eventManager, url, onEventWrapper, nil);

	return true
end

function Socket:StartConnecting(url)

	if type(url) ~= "string" then
		ERROR("Usage: Socket.StartConnecting(self : Socket, url : string)")
		return
	end

	DEBUG("Starting to connect to " .. url)

	-- Needed to pass self to the Lua event handler
	local function onEventWrapper(...)
		self:OnEvent(...)
	end
	self.outgoingConnection = mongoose.bindings.mg_connect(self.eventManager, url, onEventWrapper, nil);

	return true
end

function Socket:IsConnected()
	-- Not initialized
	if type(self.outgoingConnection) ~= "cdata" then return false end

	-- No call to mg_connect
	return (self.outgoingConnection.is_client == 1)
end

function Socket:SendData(connection, data)
	if type(connection) ~= "cdata" or type(data) ~= "string" then
		ERROR("Usage: Socket.SendData(self : Socket, connection : cdata, data : string)")
		return false
	end

	DEBUG("Sending data: " .. data)
	local success = mongoose.bindings.mg_send(connection, data, #data)
	if not success then
		ERROR("Failed to append data to the SEND buffer")
		return false
	end

	return true
end

function Socket:StartPollingWithTimeout(timeoutInMilliseconds)
	if timeoutInMilliseconds == nil then timeoutInMilliseconds = 1000 end

	while true do
		mongoose.bindings.mg_mgr_poll(self.eventManager, timeoutInMilliseconds);
	end
end

function Socket:PollOnce()
	mongoose.bindings.mg_mgr_poll(self.eventManager, 0);
end

function Socket:PollOnceWithTimeout(timeoutInMilliseconds)
	if timeoutInMilliseconds == nil then timeoutInMilliseconds = 1000 end

	mongoose.bindings.mg_mgr_poll(self.eventManager, timeoutInMilliseconds);
end

local cast = ffi.cast

local tonumber = tonumber
local string_char = string.char
local table_concat = table.concat

local function EventData_ToLuaString(eventData)
	local countedString = cast("struct mg_str *", eventData)

	local stringLength = tonumber(countedString.len)
	local charBuffer = ffi.cast("char*", countedString.ptr)
	-- There's probably a way to do this without allocations, but the returned data should be a Lua string (usability)
	local characters = {}
	for index = 0, stringLength - 1, 1 do
		characters[#characters+1] = string_char(charBuffer[index])
	end
	local luaString = table_concat(characters, "")

	return luaString
end

local function EventData_ToHttpMessage(eventData)
	-- Pointers likely aren't the most useful, but that is TBD
	return cast("struct mg_http_message *", eventData)
end

local function EventData_ToWebSocketMessage(eventData)
	-- Pointers likely aren't the most useful, but that is TBD
	return cast("struct mg_ws_message *", eventData)
end

local function EventData_LongToNumber(eventData)
	local dereferencedPointerValue = cast("long*", eventData)[0]
	local numBytesSent = tonumber(dereferencedPointerValue) - 1 -- Ignore null terminator since it's always present
	return numBytesSent
end

function Socket:OnEvent(connection, eventID, eventData, userData)
	local eventName = mongoose.events[eventID]
	-- print("OnEvent", eventName, tonumber(connection.id), tonumber(eventID))

	if eventName == "MG_EV_ERROR" then self:OnError(connection, eventData) end
	if eventName == "MG_EV_OPEN" then self:OnConnectionCreated(connection) end
	if eventName == "MG_EV_POLL" then self:OnUpdate(connection, eventData) end
	-- MG_EV_POLL = whatever , milliseconds param?
	if eventName == "MG_EV_RESOLVE" then self:OnHostNameResolved(connection) end
	if eventName == "MG_EV_CONNECT" then self:OnConnectionEstablished(connection) end
	if eventName == "MG_EV_ACCEPT" then self:OnConnectionAccepted(connection) end
	if eventName == "MG_EV_READ" then self:OnDataReceived(connection, EventData_ToLuaString(eventData)) end
	-- MG_EV_WRITE,       // Data written to socket       long *bytes_written
	if eventName == "MG_EV_WRITE" then self:OnDataWritten(connection, EventData_LongToNumber(eventData)) end
	if eventName == "MG_EV_CLOSE" then self:OnConnectionClosed(connection) end
	if eventName == "MG_EV_HTTP_MSG" then self:OnHttpMessageReceived(connection, EventData_ToHttpMessage(eventData)) end
	if eventName == "MG_EV_HTTP_CHUNK" then self:OnHttpChunkReceived(connection, EventData_ToHttpMessage(eventData)) end
	if eventName == "MG_EV_WS_OPEN" then self:OnWebSocketHandshakeCompleted(connection, EventData_ToHttpMessage(eventData)) end
	if eventName == "MG_EV_WS_MSG" then self:OnWebSocketMessageReceived(connection, EventData_ToWebSocketMessage(eventData)) end
	if eventName == "MG_EV_WS_CTL" then self:OnWebSocketControlFrameReceived(connection, EventData_ToWebSocketMessage(eventData)) end
end

function Socket:OnError(connection, error_message)

	EVENT("SOCKET_ERROR", "Connection #"  .. tonumber(connection.id))

	print(error_message)
	print(ffi.string(error_message))
	print(tostring(error_message))
end

function Socket:OnUpdate(connection, milliseconds)
	-- milliseconds = ffi.cast("uint64_t", milliseconds)
	-- print(milliseconds)
	-- EVENT("SOCKET_CONNECTION_UPDATED", tonumber(connection.id), tonumber(milliseconds))
end

function Socket:OnConnectionCreated(connection)
	EVENT("SOCKET_CONNECTION_CREATED", tonumber(connection.id))
end

function Socket:OnHostNameResolved(connection)
	EVENT("SOCKET_HOST_NAME_RESOLVED", tonumber(connection.id))
end

function Socket:OnConnectionEstablished(connection)
	EVENT("SOCKET_CONNECTION_ESTABLISHED", tonumber(connection.id))
end

function Socket:OnConnectionAccepted(connection)
	EVENT("SOCKET_CONNECTION_ACCEPTED", tonumber(connection.id))
end

function Socket:OnDataReceived(connection, mg_str)
	-- TODO str
	EVENT("SOCKET_DATA_RECEIVED", tonumber(connection.id))
end

function Socket:OnDataWritten(connection, bytes_written)
	local dereferencedPointerValue = ffi.cast("long*", bytes_written)[0]
	local numBytesSent = tonumber(dereferencedPointerValue) - 1 -- Ignore null terminator since it's always present
	EVENT("SOCKET_DATA_WRITTEN", tonumber(connection.id), numBytesSent)
end

function Socket:OnConnectionClosed(connection)
	EVENT("SOCKET_CONNECTION_CLOSED", tonumber(connection.id))
end

function Socket:OnHttpMessageReceived(connection, mg_http_message)
	-- TODO parse msg, pass length in bytes
	EVENT("HTTP_MESSAGE_RECEIVED", tonumber(connection.id))
	-- todo request/response
end

function Socket:OnHttpChunkReceived(connection, mg_http_message)
	EVENT("HTTP_CHUNK_RECEIVED", tonumber(connection.id))
end

function Socket:OnWebSocketHandshakeCompleted(connection, mg_http_message)
	EVENT("WEBSOCKET_HANDSHAKE_COMPLETED", tonumber(connection.id))
end

function Socket:OnWebSocketMessageReceived(connection, mg_ws_message)
	EVENT("WEBSOCKET_MESSAGE_RECEIVED", tonumber(connection.id))
end

function Socket:OnWebSocketControlFrameReceived(connection, mg_ws_message)
	EVENT("WEBSOCKET_CONTROL_FRAME_RECEIVED", tonumber(connection.id))
end

return Socket