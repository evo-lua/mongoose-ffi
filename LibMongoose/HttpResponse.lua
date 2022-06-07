local HttpResponse = {}

function HttpResponse:Construct()

	local instance = {
		-- TODO sane defaults
		statusCode = 201,
		statusText = "OK?",
		protocolString = "HTTP/1.0",
		headers = {
			["Content-Type"] = "text/unknown"
			-- origin?
		},
		body = "body goes here"
	}

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			if HttpResponse[v] ~= nil then
				return HttpResponse[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end


local table_concat = table.concat
local count = table.count
function HttpResponse:ConcatenateHeaders()

	if count(self.headers) ==0 then return "" end

	local keyValuePairs = {}

	for key, value in pairs(self.headers) do
		keyValuePairs[#keyValuePairs+1] = key .. ": " .. value .. "\r\n"
	end

	return table_concat(keyValuePairs, "")

end

local tonumber = tonumber
function HttpResponse:ParseHttpMessage(httpMessage)

	local response = self:Construct()

	-- mongoose only has a generic message struct, which maps very poorly to the response fields...
	response.statusCode = tonumber(httpMessage.url)
	response.statusText = httpMessage.protocolString
	response.protocolString = httpMessage.method
	response.headers = httpMessage.headers
	response.body = httpMessage.body
	response.message = httpMessage.message

	return response
end

return HttpResponse