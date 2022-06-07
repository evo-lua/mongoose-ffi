local mongoose = import("../../../mongoose.lua")
local LibMongoose = import("../../../LibMongoose.lua")

local HttpResponse = import("../../../LibMongoose/HttpResponse.lua")

local scenario = Scenario:Construct("WebSocket echo server")

local echoServerURL = "ws://127.0.0.1:1777"

local wsResponse = nil

scenario:GIVEN("I have started a local WebSocket echo server")
function scenario:OnSetup()
	local server = LibMongoose:CreateWebSocketServer()

	local WEBSOCKET_OP_CONTINUE = 0
	local WEBSOCKET_OP_TEXT=  1
	local WEBSOCKET_OP_BINARY = 2
	local WEBSOCKET_OP_CLOSE = 8
	local WEBSOCKET_OP_PING = 9
	local WEBSOCKET_OP_PONG = 10

	-- Performance
	_G.EVENT = function() end
	_G.DEBUG = function() end

	local bit = require("bit")

	function server:OnWebSocketMessageReceived(connection, mg_ws_message)
		local opCode = bit.band(mg_ws_message.flags, 0x0F) -- BITMASK_OPCODE
		EVENT("WEBSOCKET_MESSAGE_RECEIVED", tonumber(connection.id), opCode)
		-- struct mg_ws_message *wm = (struct mg_ws_message *) ev_data;
		-- int opcode = wm->flags & 0x0F;
		mongoose.bindings.mg_ws_send(connection, mg_ws_message.data.ptr, mg_ws_message.data.len, opCode)
	end
	self.server = server

	-- dump(server)
	-- self.client = LibMongoose:CreateHttpClient()
end

scenario:WHEN("I send a message to the server")
function scenario:OnRun()
	local server = self.server
	-- local client = self.client

	-- function client:OnHttpMessageReceived(connection, httpMessage)
	-- 	print("Received HTTP message", httpMessage:ToString())
	-- 	httpResponse = HttpResponse:ParseHttpMessage(httpMessage)
	-- end

	assertTrue(server:StartListening(echoServerURL), "Should be able to start the server with a valid URL")
	-- server:PollOnceWithTimeout(10) -- Start listening

	-- -- Simulate the required steps manually since the test shouldn't start the event loop
	-- -- Some delay is needed to make sure the OS can do the low-level socket stuff before OnEvaluate
	-- 	client:Fetch(echoServerURL) -- Queue HTTP request
	-- -- client:PollOnceWithTimeout(10) -- Create outbound TCP connection
	-- client:PollOnceWithTimeout(10) -- Write HTTP request
	-- server:PollOnceWithTimeout(10) -- Accept incoming TCP connection
	-- client:PollOnceWithTimeout(10) -- Write message
	-- server:PollOnceWithTimeout(10) -- Receive message (HTTP event triggers on next poll...)
	-- server:PollOnceWithTimeout(10) -- Write response
	-- client:PollOnceWithTimeout(10) -- Receive response

end

scenario:THEN("The server should echo back the data it received")
function scenario:OnEvaluate()
	-- assertEquals(httpResponse.protocolString, "HTTP/1.1", "Response should use HTTP 1.1")
	-- assertEquals(httpResponse.statusCode, 200, "Response should have a 200 status code")
	-- assertEquals(httpResponse.statusText, "OK", "Response should include status 'OK'")
	-- assertEquals(httpResponse.headers["Content-Type"], "text/plain", "Response should include a Content-Type header")
	-- assertEquals(httpResponse.headers["Content-Length"], "11", "Response should include a Content-Length header")
	-- assertEquals(httpResponse.body, "Hello HTTP!", "Response should have the expected body")
	-- -- tbd messageString?
	-- assertEquals(httpResponse.message, "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 11\r\n\r\n", "Response should be as expected")

	self.server:StartPollingWithTimeout(20)
end

return scenario