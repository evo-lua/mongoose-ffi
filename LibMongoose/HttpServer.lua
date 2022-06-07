local mongoose = import("../mongoose.lua")
local Socket = import("./Socket.lua")

local HttpServer = {}

function HttpServer:Construct()
	local instance = Socket:Construct() -- To inherit all the TCP-based APIs, which HTTP builds on

	local inheritanceLookupMetatable = {
		__index = function(t, v)

			if HttpServer[v] ~= nil then
				return HttpServer[v]
			elseif Socket[v] ~= nil then
				return Socket[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable) -- To enrich the TCP server with specific HTTP APIs

	return instance
end

function HttpServer:StartListening(url)

	if type(url) ~= "string" then
		ERROR("Usage: HttpServer.StartListening(self : HttpServer, url : string)")
		return
	end

	DEBUG("Starting to serve on " .. url)

	-- To pass self to the Lua event handler
	local function onEventWrapper(...)
		self:OnEvent(...)
	end
	self.listeningConnection = mongoose.bindings.mg_http_listen(self.eventManager, url, onEventWrapper, nil);

	return true
end

function HttpServer:OnHttpMessageReceived(connection, httpMessage)
	-- struct mg_http_serve_opts opts = {.root_dir = "."};   // Serve
	-- mg_http_serve_dir(c, ev_data, &opts);                 // static content
	print("OnHttpMessageReceived")
end

function HttpServer:SendResponse(connection, response)

	local headersString = response:ConcatenateHeaders()
	mongoose.bindings.mg_http_reply(connection, 200, headersString, response.body)
end

return HttpServer