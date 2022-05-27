-- Requires evo runtime, because I'm lazy
local mongoose = _G.import("mongoose.lua")
local LibMongoose = _G.import("LibMongoose.lua")

local TestSuite = {
	exportedApiSurface = {
		"mg_mgr_init",
		"mg_mgr_poll",
		"mg_mgr_free",
		"mg_listen",
		"mg_connect",
		"mg_send",
		"mg_printf",
		"mg_vprintf",
		"mg_straddr",
		"mg_wrapfd",
		"mg_mkpipe",
		"mg_http_listen",
		"mg_http_connect",
		"mg_http_status",
		"mg_http_get_request_len",
		"mg_http_parse",
		"mg_http_printf_chunk",
		"mg_http_write_chunk",
		"mg_http_delete_chunk",
		"mg_http_serve_dir",
		"mg_http_serve_file",
		"mg_http_reply",
		"mg_http_get_header",
		"mg_http_get_header_var",
		"mg_http_get_var",
		"mg_http_creds",
		"mg_http_match_uri",
		"mg_http_bauth",
		"mg_http_next_multipart",
		"mg_ws_connect",
		"mg_ws_upgrade",
		"mg_ws_send",
		"mg_ws_wrap",
		"mg_sntp_connect",
		"mg_sntp_request",
		"mg_mqtt_connect",
		"mg_mqtt_listen",
		"mg_mqtt_login",
		"mg_mqtt_pub",
		"mg_mqtt_sub",
		"mg_mqtt_next_sub",
		"mg_mqtt_next_unsub",
		"mg_mqtt_send_header",
		"mg_mqtt_ping",
		"mg_mqtt_parse",
		"mg_tls_init",
		"mg_tls_free",
		"mg_timer_add",
		"mg_timer_init",
		"mg_timer_free",
		"mg_timer_poll",
		"mg_millis",
		"mg_str_s",
		"mg_str_n",
		"mg_casecmp",
		"mg_ncasecmp",
		"mg_vcmp",
		"mg_vcasecmp",
		"mg_strcmp",
		"mg_strdup",
		"mg_strstr",
		"mg_strstrip",
		"mg_match",
		"mg_commalist",
		"mg_hex",
		"mg_unhex",
		"mg_unhexn",
		"mg_asprintf",
		"mg_vasprintf",
		"mg_snprintf",
		"mg_vsnprintf",
		"mg_to64",
		"mg_aton",
		"mg_ntoa",
		"mg_call",
		"mg_error",
		"mg_md5_init",
		"mg_md5_update",
		"mg_md5_final",
		"mg_sha1_init",
		"mg_sha1_update",
		"mg_sha1_final",
		"mg_base64_update",
		"mg_base64_final",
		"mg_base64_encode",
		"mg_base64_decode",
		"mg_file_read",
		"mg_file_write",
		"mg_file_printf",
		"mg_random",
		"mg_ntohs",
		"mg_ntohl",
		"mg_crc32",
		"mg_check_ip_acl",
		"mg_url_decode",
		"mg_url_encode",
		"mg_iobuf_init",
		"mg_iobuf_resize",
		"mg_iobuf_free",
		"mg_iobuf_add",
		"mg_iobuf_del",
		"mg_url_port",
		"mg_url_is_ssl",
		"mg_url_host",
		"mg_url_user",
		"mg_url_pass",
		"mg_url_uri",
		"mg_log_set",
		"mg_hexdump",
	},
	highlevelApiSurface = {

	}

}

function TestSuite:Run()
	print("Running some basic sanity tests...\n")

	self:TestLowLevelBindings()
	self:TestHighLevelAPI()

	print("All tests done!")
end


function TestSuite:TestLowLevelBindings()
	print("TEST\tmongoose.lua (low-level bindings)")

	self:TestEventConstantsAreExported()
	self:TestExportedApiSurfaceIsPresent()

	print("OK\tmongoose.lua (low-level bindings)\n")
end

function TestSuite:TestHighLevelAPI()
	print("TEST\tLibMongoose.lua (high-level API)")

	self:TestHighlevelApiSurfaceIsPresent()

	print("OK\tLibMongoose.lua (high-level API)\n")
end

function TestSuite:TestHighlevelApiSurfaceIsPresent()

	local EXPECTED_NUM_FUNCTIONS = 0
	local numFunctionsExported = 0

	for _, exportedFunctionName in ipairs(self.highlevelApiSurface) do
		assert(type(mongoose.bindings[exportedFunctionName]) == "function", "Should export function " .. exportedFunctionName)
			numFunctionsExported = numFunctionsExported + 1
		end

		assert(numFunctionsExported == EXPECTED_NUM_FUNCTIONS,
		"Should export " .. EXPECTED_NUM_FUNCTIONS .. " functions (actual: " .. numFunctionsExported.. ")")

		print("OK\tHigh-level API functions are exported")
end

function TestSuite:TestEventConstantsAreExported()

	for eventTypeID, eventName in ipairs(mongoose.events) do
		assert(type(eventName) == "string", "Should export event name for event of type " .. eventTypeID)
	end

	local EXPECTED_NUM_EVENTS = 19 -- I guess it's not changing anytime soon
	assert(#mongoose.events == EXPECTED_NUM_EVENTS,
	"Should export " .. EXPECTED_NUM_EVENTS .. " events (actual: " .. #mongoose.events.. ")")

	print("OK\tEvent constants are exported")

end

function TestSuite:TestExportedApiSurfaceIsPresent()

	local EXPECTED_NUM_FUNCTIONS = 109
	local numFunctionsExported = 0

	for _, exportedFunctionName in ipairs(self.exportedApiSurface) do
		assert(type(mongoose.bindings[exportedFunctionName]) == "cdata", "Should export function " .. exportedFunctionName)
			numFunctionsExported = numFunctionsExported + 1
		end

		assert(numFunctionsExported == EXPECTED_NUM_FUNCTIONS,
		"Should export " .. EXPECTED_NUM_FUNCTIONS .. " functions (actual: " .. numFunctionsExported.. ")")

		print("OK\tLow-level API functions are exported")
end

TestSuite:Run()