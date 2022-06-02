local MongooseServer = {}

-- HTTP

-- HttpResponse
-- mg_http_status
-- mg_http_get_header mg_http_get_header_var	mg_http_get_var	mg_http_creds

-- HttpRequest
-- mg_http_get_request_len
-- mg_http_get_header mg_http_get_header_var	mg_http_get_var	mg_http_creds
-- CreateFromString mg_http_parse

-- HttpServer ServeFile, ServeDirectory mg_http_serve_opts mg_http_serve_dir	mg_http_serve_file
-- SendReply mg_http_reply
-- HttpClient

-- multipart, chunked encoding, basic auth, ... ? mg_http_part mg_http_next_multipart

-- WebSocket

-- WebSocketMessage mg_ws_message

-- WebSocketServer, WebSocketClient
-- mg_ws_connect
-- UpgradeConnection	mg_ws_upgrade
-- SendMessage	mg_ws_send


--- TLS Support

-- mg_tls_opts
-- SecureConnection	mg_tls_init



function MongooseServer:OnEvent(eventTypeID, ...)

end

function MongooseServer:Construct()
	-- mg_mgr_init
end

function MongooseServer:Destroy()
	-- mg_mgr_free
end

function MongooseServer:StartListening()
-- mg_listen
-- mg_http_listen
end

function MongooseServer:StartConnecting()
	-- mg_connect
	-- mg_http_connect
end

function MongooseServer:QueueMessage()
	-- mg_send
end

function MongooseServer:StopListening() end

function MongooseServer:PollWithTimeout()
-- mg_mgr_poll
end

function MongooseServer:GetNumConnectedPeers() end
function MongooseServer:GetPeerInfo() end

function MongooseServer:UpgradeConnection()
-- mg_ws_upgrade
end

function MongooseServer:Construct() end
function MongooseServer:Construct() end



return MongooseServer