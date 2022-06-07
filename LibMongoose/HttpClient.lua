local mongoose = import("../mongoose.lua")
local Socket = import("./Socket.lua")
local HttpRequest = import("./HttpRequest.lua")

local HttpClient = {}

function HttpClient:Construct()
	local instance = Socket:Construct() -- To inherit all the TCP-based APIs, which HTTP builds on

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			-- print("HttpClient", v)
			if HttpClient[v] ~= nil then
				return HttpClient[v]
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

function HttpClient:StartConnecting(url)

	if type(url) ~= "string" then
		ERROR("Usage: HttpClient.StartConnecting(self : HttpClient, url : string)")
		return
	end

	DEBUG("Starting to connect to " .. url .. " (via HTTP)")

	-- Needed to pass self to the Lua event handler
	local function onEventWrapper(...)
		-- print("HttpClient:OnEvent()", ...)
		self:OnEvent(...)
	end
	self.outgoingConnection = mongoose.bindings.mg_http_connect(self.eventManager, url, onEventWrapper, nil);

	return true
end

function HttpClient:OnHttpMessageReceived(connection, httpMessage)
	-- struct mg_http_serve_opts opts = {.root_dir = "."};   // Serve
	-- mg_http_serve_dir(c, ev_data, &opts);                 // static content
	print("OnHttpMessageReceived")
end

function HttpClient:OnConnectionEstablished(connection)
		print("HttpClient", "OnConnectionEstablished")
end

function HttpClient:Fetch(url, method)

	url = url or "http://localhost:80"
	method = method or "GET"

	DEBUG(format("Fetching URL: %s (method: %s)", url, method))

	method = method or "GET"
	function self:OnConnectionEstablished(connection)
		print("FETCH", "OnConnectionEstablished")

		local request = HttpRequest:Construct(url, method)
		self:SendData(connection, request:ToString())
	end
	self:StartConnecting(url)
	-- self:PollOnce()
	-- coroutine.yield()
end

return HttpClient