local mongoose = import("../../../mongoose.lua")
local LibMongoose = import("../../../LibMongoose.lua")

local HttpResponse = import("../../../LibMongoose/HttpResponse.lua")

local scenario = Scenario:Construct("HTTP echo server")

local echoServerURL = "http://127.0.0.1:54321"

local hasClientQueuedData = false
local hasClientWrittenData = false
local hasServerReceivedData = false
local hasServerQueuedResponse = false
local hasServerWrittenResponse = false
local hasClientReceivedResponse = false

local httpResponse = nil

local ffi = require("ffi")

scenario:GIVEN("I have started a local HTTP server that returns some plain text")
function scenario:OnSetup()
	local server = LibMongoose.CreateHttpServer()

	function server:OnHttpMessageReceived(connection, httpMessage)
		local response = HttpResponse:Construct()
		response.statusCode = 200
		response.headers = {
			["Content-Type"] = "text/plain"
		}
		response.body = "Hello HTTP!"

		server:SendResponse(connection, response)
		hasServerQueuedResponse = true
	end
	self.server = server
	self.client = LibMongoose:CreateHttpClient()
end

scenario:WHEN("I send a GET request for the / resource")
function scenario:OnRun()
	local server = self.server
	local client = self.client

	function client:OnHttpMessageReceived(connection, httpMessage)
		print("Received HTTP message", httpMessage:ToString())
		httpResponse = HttpResponse:ParseHttpMessage(httpMessage)
	end

	assertTrue(server:StartListening(echoServerURL), "Should be able to start the server with a valid URL")
	server:PollOnceWithTimeout(10) -- Start listening

	-- Simulate the required steps manually since the test shouldn't start the event loop
	-- Some delay is needed to make sure the OS can do the low-level socket stuff before OnEvaluate
		client:Fetch(echoServerURL) -- Queue HTTP request
	-- client:PollOnceWithTimeout(10) -- Create outbound TCP connection
	client:PollOnceWithTimeout(10) -- Write HTTP request
	server:PollOnceWithTimeout(10) -- Accept incoming TCP connection
	client:PollOnceWithTimeout(10) -- Write message
	server:PollOnceWithTimeout(10) -- Receive message (HTTP event triggers on next poll...)
	server:PollOnceWithTimeout(10) -- Write response
	client:PollOnceWithTimeout(10) -- Receive response

end

scenario:THEN("The server should respond with some placeholder text")
function scenario:OnEvaluate()
	assertEquals(httpResponse.protocolString, "HTTP/1.1", "Response should use HTTP 1.1")
	assertEquals(httpResponse.statusCode, 200, "Response should have a 200 status code")
	assertEquals(httpResponse.statusText, "OK", "Response should include status 'OK'")
	assertEquals(httpResponse.headers["Content-Type"], "text/plain", "Response should include a Content-Type header")
	assertEquals(httpResponse.headers["Content-Length"], "11", "Response should include a Content-Length header")
	assertEquals(httpResponse.body, "Hello HTTP!", "Response should have the expected body")
	-- tbd messageString?
	assertEquals(httpResponse.message, "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 11\r\n\r\n", "Response should be as expected")
end

return scenario