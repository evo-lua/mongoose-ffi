local scenario = Scenario:Construct("Creating TCP servers")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to start a TCP server")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end

function scenario:OnEvaluate()

	local port = 1234
	local host = "127.0.0.1"
	local server = self.api.CreateTcpServer()

	assertFalse(server:IsListening(), "Should not be started automatically")
	assertTrue(server:StartListening(port, host), "Should be able to start the server with a valid port and host name")
	-- assertTrue(server:StopListening(), "Should be able to stop the server after is was started with a valid port and host name")
	-- assertTrue(server:StartListening(), "Should be able to start the server with a default port and host name")
	assertTrue(server:IsListening(), "Should be able to start the server manually")

	assertFalse(server:IsEchoServer(), "Should turn echo server mode OFF by default")
	server:EnableEchoServerMode()
	assertTrue(server:IsEchoServer(), "Should be able to turn echo server mode ON")
	server:DisableEchoServerMode()
	assertFalse(server:IsEchoServer(), "Should be able to turn echo server mode OFF")


	local expectedURL = "tcp://127.0.0.1:1234"
	assertEquals(server:GetURL(), expectedURL, "Should use the configured port and host")

	-- static void cb(struct mg_connection *c, int ev, void *ev_data, void *fn_data) {
	-- 	if (ev == MG_EV_READ) {
	-- 	  mg_send(c, c->recv.buf, c->recv.len);     // Echo received data back
	-- 	  mg_iobuf_del(&c->recv, 0, c->recv.len);   // And discard it
	-- 	}
	--   }

	--   int main(int argc, char *argv[]) {
	-- 	struct mg_mgr mgr;
	-- 	mg_mgr_init(&mgr);                                // Init manager
	-- 	mg_listen(&mgr, "tcp://0.0.0.0:1234", cb, &mgr);  // Setup listener
	-- 	for (;;) mg_mgr_poll(&mgr, 1000);                 // Event loop
	-- 	mg_mgr_free(&mgr);                                // Cleanup
	-- 	return 0;
	--   }

end

return scenario