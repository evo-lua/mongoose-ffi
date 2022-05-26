local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")

local WINDOWS_SHARED_LIBRARY_EXTENSION = "dll"
local UNIX_SHARED_LIBRARY_EXTENSION = "so"
local expectedFileExtension = isWindows and WINDOWS_SHARED_LIBRARY_EXTENSION or UNIX_SHARED_LIBRARY_EXTENSION
local bindings = ffi.load("mongoose_ffi" .. "." .. expectedFileExtension)


local mongoose = {
	cdefs = [[
		struct mg_addr {
			uint16_t port;    // TCP or UDP port in network byte order
			uint32_t ip;      // IP address in network byte order
			uint8_t ip6[16];  // IPv6 address
			bool is_ip6;      // True when address is IPv6 address
		  };

		struct mg_iobuf {
			unsigned char *buf;  // Pointer to stored data
			size_t size;         // Total size available
			size_t len;          // Current number of bytes
		  };

		  typedef void (*mg_event_handler_t)(struct mg_connection *, int ev,
		  void *ev_data, void *fn_data);

		struct mg_connection {
			struct mg_connection *next;  // Linkage in struct mg_mgr :: connections
			struct mg_mgr *mgr;          // Our container
			struct mg_addr loc;          // Local address
			struct mg_addr rem;          // Remote address
			void *fd;                    // Connected socket, or LWIP data
			unsigned long id;            // Auto-incrementing unique connection ID
			struct mg_iobuf recv;        // Incoming data
			struct mg_iobuf send;        // Outgoing data
			mg_event_handler_t fn;       // User-specified event handler function
			void *fn_data;               // User-specified function parameter
			mg_event_handler_t pfn;      // Protocol-specific handler function
			void *pfn_data;              // Protocol-specific function parameter
			char label[50];              // Arbitrary label
			void *tls;                   // TLS specific data
			unsigned is_listening : 1;   // Listening connection
			unsigned is_client : 1;      // Outbound (client) connection
			unsigned is_accepted : 1;    // Accepted (server) connection
			unsigned is_resolving : 1;   // Non-blocking DNS resolution is in progress
			unsigned is_connecting : 1;  // Non-blocking connect is in progress
			unsigned is_tls : 1;         // TLS-enabled connection
			unsigned is_tls_hs : 1;      // TLS handshake is in progress
			unsigned is_udp : 1;         // UDP connection
			unsigned is_websocket : 1;   // WebSocket connection
			unsigned is_hexdumping : 1;  // Hexdump in/out traffic
			unsigned is_draining : 1;    // Send remaining data, then close and free
			unsigned is_closing : 1;     // Close and free the connection immediately
			unsigned is_readable : 1;    // Connection is ready to read
			unsigned is_writable : 1;    // Connection is ready to write
		  };

		struct mg_dns {
			const char *url;          // DNS server URL
			struct mg_connection *c;  // DNS server connection
		  };

		struct mg_timer {
			uint64_t period_ms;       // Timer period in milliseconds
			uint64_t prev_ms;         // Timestamp of a previous poll
			uint64_t expire;          // Expiration timestamp in milliseconds
			unsigned flags;           // Possible flags values below
			void (*fn)(void *);       // Function to call
			void *arg;                // Function argument
			struct mg_timer *next;    // Linkage
		  };

		struct mg_mgr {
			struct mg_connection *conns;  // List of active connections
			struct mg_dns dns4;           // DNS for IPv4
			struct mg_dns dns6;           // DNS for IPv6
			int dnstimeout;               // DNS resolve timeout in milliseconds
			bool use_dns6;                // Use DNS6 server by default, see #1532
			unsigned long nextid;         // Next connection ID
			void *userdata;               // Arbitrary user data pointer
			uint16_t mqtt_id;             // MQTT IDs for pub/sub
			void *active_dns_requests;    // DNS requests in progress
			struct mg_timer *timers;      // Active timers
			void *priv;                   // Used by the experimental stack
			size_t extraconnsize;         // Used by the experimental stack
		};


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		typedef struct mg_mgr MongooseEventManager;

		typedef struct MongooseEvent {
			int eventTypeID;
			void* eventArguments;
			struct MongooseEvent* next;
			struct MongooseEvent* prev;
		} MongooseEvent;

		MongooseEventManager MongooseEventManager_CreateHttpServer();
		void MongooseEventManager_PollOnceWithTimeout(MongooseEventManager eventManager, int timeoutInMilliseconds);
		//MongooseEvent MongooseEventManager_GetNextQueuedEvent();
	]]
}

ffi.cdef(mongoose.cdefs)

local server = bindings.MongooseEventManager_CreateHttpServer()
while true do
	bindings.MongooseEventManager_PollOnceWithTimeout(server, 1000)
	-- local event = bindings.MongooseEventManager_GetNextQueuedEvent(server)

	-- Process queued events for all active connections
	local connections = server.conns
	local connection = connections
	while connection ~= nil do

		-- print(connection == nil)
		-- print(type(connection))
		-- print(connection.next == nil)
		-- print(type(connection.next))
		print("Processing queued events for connection " .. tonumber(connection.id))

		local nextEvent = ffi.cast("MongooseEvent*", connection.fn_data)

		while(nextEvent ~= nil) do

			print("Dumping event cdata (don't try this at home)")
			print(nextEvent.eventTypeID) -- TODO LUT
			print(nextEvent.eventArguments)
			print(nextEvent.next)
			print(nextEvent.prev)

			nextEvent = nextEvent.next
		end

		print("Processed queued events for connection " .. tonumber(connection.id))
		connection = connection.next
	end

	-- local eventID = tonumber(event.eventTypeID)
	-- local eventArgs = "TODO"
	-- print("Detected new event: " .. eventID .. " (Args: " .. eventArgs .. ")")

	-- Remove from event queue

	print("Polling loop finished")
end