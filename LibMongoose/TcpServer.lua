
local MongooseEventManager = import("./MongooseEventManager.lua")

---- TCP Server
local TcpServer = {}

function TcpServer:Construct()
	local instance = MongooseEventManager:Construct("tcp")

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			if TcpServer[v] then
				return TcpServer[v]
			elseif MongooseEventManager[v] then
				return MongooseEventManager[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

function TcpServer:OnDataReceived(connection, mg_str)

	if self.isEchoServer then self:EchoLastReceivedMessage(connection) end

		-- mg_send(c, c->recv.buf, c->recv.len);     // Echo received data back
		-- mg_iobuf_del(&c->recv, 0, c->recv.len);   // And discard it
end

return TcpServer