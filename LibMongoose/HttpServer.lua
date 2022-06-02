
local HttpServer = {}

function HttpServer:Construct()

end

function HttpServer:IsListening()

end

function HttpServer:StartListening(port, host)
	port = port or 80
	host = host or "0.0.0.0"
end

return HttpServer