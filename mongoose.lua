local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")

local WINDOWS_SHARED_LIBRARY_EXTENSION = "dll"
local UNIX_SHARED_LIBRARY_EXTENSION = "so"
local expectedFileExtension = isWindows and WINDOWS_SHARED_LIBRARY_EXTENSION or UNIX_SHARED_LIBRARY_EXTENSION
local bindings = ffi.load("mongoose" .. "." .. expectedFileExtension)

local mongoose = {}
mongoose.bindings = bindings

-- EventTypeID:FriendlyName -- Description:eventData value type (passed as first parameter to the callback)
mongoose.events = {
	"MG_EV_ERROR",       -- Error                        char *error_message
	"MG_EV_OPEN",        -- Connection created           NULL
	"MG_EV_POLL",        -- mg_mgr_poll iteration        uint64_t *milliseconds
	"MG_EV_RESOLVE",     -- Host name is resolved        NULL
	"MG_EV_CONNECT",     -- Connection established       NULL
	"MG_EV_ACCEPT",      -- Connection accepted          NULL
	"MG_EV_READ",        -- Data received from socket    struct mg_str *
	"MG_EV_WRITE",       -- Data written to socket       long *bytes_written
	"MG_EV_CLOSE",       -- Connection closed            NULL
	"MG_EV_HTTP_MSG",    -- HTTP request/response        struct mg_http_message *
	"MG_EV_HTTP_CHUNK",  -- HTTP chunk (partial msg)     struct mg_http_message *
	"MG_EV_WS_OPEN",     -- Websocket handshake done     struct mg_http_message *
	"MG_EV_WS_MSG",      -- Websocket msg, text or bin   struct mg_ws_message *
	"MG_EV_WS_CTL",      -- Websocket control msg        struct mg_ws_message *
	"MG_EV_MQTT_CMD",    -- MQTT low-level command       struct mg_mqtt_message *
	"MG_EV_MQTT_MSG",    -- MQTT PUBLISH received        struct mg_mqtt_message *
	"MG_EV_MQTT_OPEN",   -- MQTT CONNACK received        int *connack_status_code
	"MG_EV_SNTP_TIME",   -- SNTP time received           uint64_t *milliseconds
	"MG_EV_USER",        -- Starting ID for user events
}

mongoose.cdefs = [[
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

		struct mg_str {
			const char *ptr;  // Pointer to string data
			size_t len;       // String len
		  };
		struct mg_str mg_str_s(const char *s);

		void mg_mgr_poll(struct mg_mgr *, int ms);
		void mg_mgr_init(struct mg_mgr *);
		void mg_mgr_free(struct mg_mgr *);
		struct mg_connection *mg_listen(struct mg_mgr *, const char *url,
		mg_event_handler_t fn, void *fn_data);
		struct mg_connection *mg_connect(struct mg_mgr *, const char *url,
		 mg_event_handler_t fn, void *fn_data);
		struct mg_connection *mg_wrapfd(struct mg_mgr *mgr, int fd,
		mg_event_handler_t fn, void *fn_data);
		bool mg_send(struct mg_connection *, const void *, size_t);
		size_t mg_printf(struct mg_connection *, const char *fmt, ...);
		size_t mg_vprintf(struct mg_connection *, const char *fmt, va_list ap);
		char *mg_straddr(struct mg_addr *, char *, size_t);
		int mg_mkpipe(struct mg_mgr *, mg_event_handler_t, void *);
		struct mg_connection *mg_http_listen(struct mg_mgr *, const char *url,
		mg_event_handler_t fn, void *fn_data);
struct mg_connection *mg_http_connect(struct mg_mgr *, const char *url,
		 mg_event_handler_t fn, void *fn_data);
		int mg_http_status(const struct mg_http_message *hm);
		int mg_http_get_request_len(const unsigned char *buf, size_t buf_len);
		int mg_http_parse(const char *s, size_t len, struct mg_http_message *);
		void mg_http_printf_chunk(struct mg_connection *cnn, const char *fmt, ...);
		void mg_http_write_chunk(struct mg_connection *c, const char *buf, size_t len);
		void mg_http_delete_chunk(struct mg_connection *c, struct mg_http_message *hm);
		void mg_http_serve_dir(struct mg_connection *, struct mg_http_message *hm,
		const struct mg_http_serve_opts *);
void mg_http_serve_file(struct mg_connection *, struct mg_http_message *hm,
		 const char *path, const struct mg_http_serve_opts *);
		 void mg_http_reply(struct mg_connection *, int status_code, const char *headers,
		 const char *body_fmt, ...);
		struct mg_str *mg_http_get_header(struct mg_http_message *, const char *name);
		struct mg_str mg_http_get_header_var(struct mg_str s, struct mg_str v);
		int mg_http_get_var(const struct mg_str *, const char *name, char *, size_t);
		void mg_http_creds(struct mg_http_message *, char *, size_t, char *, size_t);
		bool mg_http_match_uri(const struct mg_http_message *, const char *glob);
		void mg_http_bauth(struct mg_connection *, const char *user, const char *pass);
		size_t mg_http_next_multipart(struct mg_str, size_t, struct mg_http_part *);
		struct mg_connection *mg_ws_connect(struct mg_mgr *, const char *url,
                                    mg_event_handler_t fn, void *fn_data,
                                    const char *fmt, ...);
		void mg_ws_upgrade(struct mg_connection *, struct mg_http_message *,
									const char *fmt, ...);
		size_t mg_ws_send(struct mg_connection *, const char *buf, size_t len, int op);
		size_t mg_ws_wrap(struct mg_connection *, size_t len, int op);
		struct mg_connection *mg_sntp_connect(struct mg_mgr *mgr, const char *url,
                                      mg_event_handler_t fn, void *fn_data);
		void mg_sntp_request(struct mg_connection *c);
		struct mg_connection *mg_mqtt_connect(struct mg_mgr *, const char *url,
		const struct mg_mqtt_opts *opts,
		mg_event_handler_t fn, void *fn_data);
		struct mg_connection *mg_mqtt_listen(struct mg_mgr *mgr, const char *url,
	   mg_event_handler_t fn, void *fn_data);
		void mg_mqtt_login(struct mg_connection *c, const struct mg_mqtt_opts *opts);
		void mg_mqtt_pub(struct mg_connection *c, struct mg_str topic,
		struct mg_str data, int qos, bool retain);
		void mg_mqtt_sub(struct mg_connection *, struct mg_str topic, int qos);
		size_t mg_mqtt_next_sub(struct mg_mqtt_message *msg, struct mg_str *topic,
		uint8_t *qos, size_t pos);
		size_t mg_mqtt_next_unsub(struct mg_mqtt_message *msg, struct mg_str *topic,
		  size_t pos);
		void mg_mqtt_send_header(struct mg_connection *, uint8_t cmd, uint8_t flags,
		  uint32_t len);
		void mg_mqtt_ping(struct mg_connection *);
		int mg_mqtt_parse(const uint8_t *buf, size_t len, struct mg_mqtt_message *m);
		void mg_tls_init(struct mg_connection *, const struct mg_tls_opts *);
		void mg_tls_free(struct mg_connection *);
		struct mg_timer *mg_timer_add(struct mg_mgr *mgr, uint64_t milliseconds,
                              unsigned flags, void (*fn)(void *), void *arg);
		void mg_timer_init(struct mg_timer **head, struct mg_timer *timer,
							  uint64_t milliseconds, unsigned flags, void (*fn)(void *),
							  void *arg);
		void mg_timer_free(struct mg_timer **head, struct mg_timer *);
		void mg_timer_poll(struct mg_timer **head, uint64_t new_ms);
		uint64_t mg_millis(void);
		struct mg_str mg_str(const char *s);
		struct mg_str mg_str_n(const char *s, size_t n);
		int mg_ncasecmp(const char *s1, const char *s2, size_t len);
		int mg_casecmp(const char *s1, const char *s2);
		int mg_vcmp(const struct mg_str *s1, const char *s2);
		int mg_vcasecmp(const struct mg_str *str1, const char *str2);
		int mg_strcmp(const struct mg_str str1, const struct mg_str str2);
		struct mg_str mg_strstrip(struct mg_str s);
		struct mg_str mg_strdup(const struct mg_str s);
		const char *mg_strstr(const struct mg_str haystack, const struct mg_str needle);
		bool mg_match(struct mg_str str, struct mg_str pattern, struct mg_str *caps);
		bool mg_commalist(struct mg_str *s, struct mg_str *k, struct mg_str *v);
		char *mg_hex(const void *buf, size_t len, char *dst);
		void mg_unhex(const char *buf, size_t len, unsigned char *to);
		unsigned long mg_unhexn(const char *s, size_t len);
		size_t mg_asprintf(char **, size_t, const char *fmt, ...);
		size_t mg_vasprintf(char **buf, size_t size, const char *fmt, va_list ap);
		size_t mg_vsnprintf(char *buf, size_t len, const char *fmt, va_list ap);
		size_t mg_snprintf(char *, size_t, const char *fmt, ...);
		int64_t mg_to64(struct mg_str str);
		bool mg_aton(struct mg_str str, struct mg_addr *addr);
		char *mg_ntoa(const struct mg_addr *addr, char *buf, size_t len);
		void mg_call(struct mg_connection *c, int ev, void *ev_data);
		void mg_error(struct mg_connection *c, const char *fmt, ...);
		typedef struct {
			uint32_t buf[4];
			uint32_t bits[2];
			unsigned char in[64];
		  } mg_md5_ctx;
		void mg_md5_init(mg_md5_ctx *c);
		void mg_md5_update(mg_md5_ctx *c, const unsigned char *data, size_t len);
		void mg_md5_final(mg_md5_ctx *c, unsigned char[16]);
		typedef struct {
			uint32_t state[5];
			uint32_t count[2];
			unsigned char buffer[64];
		  } mg_sha1_ctx;
		void mg_sha1_init(mg_sha1_ctx *);
		void mg_sha1_update(mg_sha1_ctx *, const unsigned char *data, size_t len);
		void mg_sha1_final(unsigned char digest[20], mg_sha1_ctx *);
		int mg_base64_update(unsigned char p, char *to, int len);
		int mg_base64_final(char *to, int len);
		int mg_base64_encode(const unsigned char *p, int n, char *to);
		int mg_base64_decode(const char *src, int n, char *dst);
		char *mg_file_read(struct mg_fs *fs, const char *path, size_t *size);
		bool mg_file_write(struct mg_fs *fs, const char *path, const void *, size_t);
		bool mg_file_printf(struct mg_fs *fs, const char *path, const char *fmt, ...);
		void mg_random(void *buf, size_t len);
		uint16_t mg_ntohs(uint16_t net);
		uint32_t mg_ntohl(uint32_t net);
		uint32_t mg_crc32(uint32_t crc, const char *buf, size_t len);
		int mg_check_ip_acl(struct mg_str acl, uint32_t remote_ip);
		int mg_url_decode(const char *s, size_t n, char *to, size_t to_len, int form);
		size_t mg_url_encode(const char *s, size_t n, char *buf, size_t len);

		int mg_iobuf_init(struct mg_iobuf *, size_t);
		int mg_iobuf_resize(struct mg_iobuf *, size_t);
		void mg_iobuf_free(struct mg_iobuf *);
		size_t mg_iobuf_add(struct mg_iobuf *, size_t, const void *, size_t, size_t);
		size_t mg_iobuf_del(struct mg_iobuf *, size_t ofs, size_t len);

		unsigned short mg_url_port(const char *url);
		int mg_url_is_ssl(const char *url);
		struct mg_str mg_url_host(const char *url);
		struct mg_str mg_url_user(const char *url);
		struct mg_str mg_url_pass(const char *url);
		const char *mg_url_uri(const char *url);
		void mg_log_set(const char *spec);
		void mg_hexdump(const void *buf, size_t len);
]]

ffi.cdef(mongoose.cdefs)

return mongoose