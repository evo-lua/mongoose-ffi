local LibMongoose = import("../../../LibMongoose.lua")
local scenario = Scenario:Construct("TCP echo server")

local echoServerURL = "tcp://127.0.0.1:1234"

local hasClientQueuedData = false
local hasClientWrittenData = false
local hasServerReceivedData = false
local hasServerQueuedResponse = false
local hasServerWrittenResponse = false
local hasClientReceivedResponse = false

scenario:GIVEN("I have started a local TCP echo server and client")
function scenario:OnSetup()
	self.server = LibMongoose.CreateSocket()
	self.client = LibMongoose.CreateSocket()
end

scenario:WHEN("The client sends some data to the server")
function scenario:OnRun()
	local server = self.server
	local client = self.client

	function client:OnConnectionEstablished(connection)
		client:SendData(connection, "Hello world!")
		hasClientQueuedData = true
	end

	function client:OnDataReceived(connection, receivedData)
		DEBUG("Received data: " .. receivedData)
		hasClientReceivedResponse = (receivedData == "Hello world!")
		self:ClearReceiveBuffer(connection) -- Discard processed messages
	end

	function client:OnDataWritten(connection, numBytesWritten)
		DEBUG("Bytes written to socket: " .. numBytesWritten)
		hasClientWrittenData = true
	end

	function server:OnDataReceived(connection, receivedData)
		DEBUG("Received data: " .. receivedData)
		hasServerReceivedData = (receivedData == "Hello world!")
		self:EchoLastReceivedMessage(connection)
		hasServerQueuedResponse = true
	end

	function server:OnDataWritten(connection, numBytesWritten)
		DEBUG("Bytes written to socket: " .. numBytesWritten)
		hasServerWrittenResponse = true
	end

	-- Basic sanity checks (these aren't counted as part of the scenario; they will however fail loudly)
	assertFalse(server:IsListening(), "Should not start the server automatically")
	assertFalse(server:IsUDP(), "Should not open a UDP connection before the server was started")
	assertFalse(server:IsTCP(), "Should not open a TCP connection before the server was started")

	assertFalse(client:IsListening(), "Should not connect to the server automatically")
	assertFalse(client:IsUDP(), "Should not open a UDP connection before the client connects")
	assertFalse(client:IsTCP(), "Should not open a TCP connection before the client connects")

	assertTrue(server:StartListening(echoServerURL), "Should be able to start the server with a valid URL")
	assertTrue(client:StartConnecting(echoServerURL), "Should be able to connect to the echo server")

	-- Simulate the required steps manually since the test shouldn't start the event loop
	-- Some delay is needed to make sure the OS can do the low-level socket stuff before OnEvaluate
	server:PollOnceWithTimeout(10) -- Start listening
	client:PollOnceWithTimeout(10) -- Connect to server
	client:PollOnceWithTimeout(10) -- Write message
	server:PollOnceWithTimeout(10) -- Receive message
	server:PollOnceWithTimeout(10) -- Write response
	client:PollOnceWithTimeout(10) -- Receive response

end

scenario:THEN("The server should echo the received data")
function scenario:OnEvaluate()
	local server = self.server
	local client = self.client

	-- All of this should have happened in the polling steps (OnRun)
	assertTrue(server:IsListening(), "Should be able to start the server manually")
	assertFalse(server:IsUDP(), "Should not open a UDP connection when the server is started")
	assertTrue(server:IsTCP(), "Should open a TCP connection when the server is started")

	assertTrue(client:IsConnected(), "Should be able to connect the client manually")
	assertFalse(client:IsUDP(), "Should not open a UDP connection when the client connects")
	assertTrue(client:IsTCP(), "Should open a TCP connection when the client connects")

	assertTrue(hasClientQueuedData, "Client should have queued data to send")
	assertTrue(hasClientWrittenData, "Client should have written data to the socket")
	assertTrue(hasServerReceivedData, "Server should have received the data")
	assertTrue(hasServerQueuedResponse, "Server should have queued a response")
	assertTrue(hasServerWrittenResponse, "Server should have written the response to the socket")
	assertTrue(hasClientReceivedResponse, "Client should have received the response")

	assertEquals(client:GetSendBuffer(), "", "Should clear the client's SEND buffer")
	assertEquals(client:GetReceiveBuffer(), "", "Should clear the client's RECV buffer")
	assertEquals(server:GetSendBuffer(), "", "Should clear the server's SEND buffer")
	assertEquals(server:GetReceiveBuffer(), "", "Should clear the server's RECV buffer")

end

return scenario