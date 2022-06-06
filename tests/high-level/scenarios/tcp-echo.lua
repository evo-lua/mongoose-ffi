local LibMongoose = import("../../../LibMongoose.lua")

local scenario = Scenario:Construct("TCP echo server")

scenario:GIVEN("I have started a local TCP echo server and client")
scenario:WHEN("A client sends some data to the server")
scenario:THEN("The server should echo the received data")

local echoServerURL = "tcp://127.0.0.1:1234"

function scenario:OnRun()

end

function scenario:OnSetup()

end

function scenario:OnEvaluate()
	local server = LibMongoose.CreateSocket()

	assertFalse(server:IsListening(), "Should not start the server automatically")
	assertFalse(server:IsUDP(), "Should not open a UDP connection before the server was started")
	assertFalse(server:IsTCP(), "Should not open a TCP connection before the server was started")

	assertTrue(server:StartListening(echoServerURL), "Should be able to start the server with a valid URL")
	assertTrue(server:IsListening(), "Should be able to start the server manually")
	assertFalse(server:IsUDP(), "Should not open a UDP connection when the server is started")
	assertTrue(server:IsTCP(), "Should open a TCP connection when the server is started")

	local client = LibMongoose.CreateSocket()
	assertFalse(client:IsListening(), "Should not connect to the server automatically")
	assertFalse(client:IsUDP(), "Should not open a UDP connection before the client connects")
	assertFalse(client:IsTCP(), "Should not open a TCP connection before the client connects")

	assertTrue(client:StartConnecting(echoServerURL), "Should be able to connect to the echo server")
	assertTrue(client:IsConnected(), "Should be able to connect the client manually")
	assertFalse(client:IsUDP(), "Should not open a UDP connection when the client connects")
	assertTrue(client:IsTCP(), "Should open a TCP connection when the client connects")

	local hasClientQueuedData = false
	local hasClientWrittenData = false
	local hasServerReceivedData = false
	local hasServerQueuedResponse = false
	local hasServerWrittenResponse = false
	local hasClientReceivedResponse = false

	function client:OnConnectionEstablished(connection)
		client:SendData(connection, "Hello world!")
		hasClientQueuedData = true
	end

	function client:OnDataReceived(connection, receivedData)
		DEBUG("Received data: " .. receivedData)
		hasClientReceivedResponse = (receivedData == "Hello world!")
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

	server:PollOnce() -- Start listening
	client:PollOnce() -- Connect to server
	client:PollOnce() -- Write message
	server:PollOnce() -- Receive message
	server:PollOnce() -- Write response
	client:PollOnce() -- Receive response

	assertTrue(hasClientQueuedData, "Client should have queued data to send")
	assertTrue(hasClientWrittenData, "Client should have written data to the socket")
	assertTrue(hasServerReceivedData, "Server should have received the data")
	assertTrue(hasServerQueuedResponse, "Server should have queued a response")
	assertTrue(hasServerWrittenResponse, "Server should have written response to the socket")
	assertTrue(hasClientReceivedResponse, "Client should have received the response")

end

return scenario