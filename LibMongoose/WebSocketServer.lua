local mongoose = import("../mongoose.lua")
local Socket = import("./Socket.lua")
local HttpServer = import("./HttpServer.lua")

local WebSocketServer = {}

function WebSocketServer:Construct()

	local instance = Socket:Construct() -- To inherit all the HTTP-based APIs, which WS builds on

	local inheritanceLookupMetatable = {
		__index = function(t, v)

			if WebSocketServer[v] ~= nil then
				return WebSocketServer[v]
			elseif HttpServer[v] ~= nil then
				return HttpServer[v]
			elseif Socket[v] ~= nil then
				return Socket[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable) -- To enrich the HTTP server with specific WS APIs

	return instance
end

-- function WebSocketServer:StartListening(url)

-- 	if type(url) ~= "string" then
-- 		ERROR("Usage: WebSocketServer.StartListening(self : WebSocketServer, url : string)")
-- 		return
-- 	end

-- 	DEBUG("Starting to serve on " .. url)

-- 	-- To pass self to the Lua event handler
-- 	local function onEventWrapper(...)
-- 		self:OnEvent(...)
-- 	end
-- 	self.listeningConnection = mongoose.bindings.mg_http_listen(self.eventManager, url, onEventWrapper, nil);

-- 	return true
-- end

function WebSocketServer:OnHttpMessageReceived(connection, httpMessage)
	-- print("WebSocketServer::OnHttpMessageReceived")
	mongoose.bindings.mg_ws_upgrade(connection, httpMessage.cdata, nil)
	-- if is upgraded then return end
end

-- function WebSocketServer:SendResponse(connection, response)

-- 	local headersString = response:ConcatenateHeaders()
-- 	mongoose.bindings.mg_http_reply(connection, 200, headersString, response.body)
-- end

return WebSocketServer