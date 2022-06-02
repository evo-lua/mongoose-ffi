
local MongooseEventManager = import("./MongooseEventManager.lua")

---- TCP Server
local TcpServer = {}

function TcpServer:Construct()
	local instance = MongooseEventManager:Construct()

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
	-- Override defaults since the prototype has to be generic (and less specific)
	instance.protocol = "tcp"

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

return TcpServer