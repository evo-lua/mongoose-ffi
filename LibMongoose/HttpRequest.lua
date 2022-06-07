local HttpRequest = {}

function HttpRequest:Construct(url, method)
	local instance = {
		headers = {},
		body = {},
		url = url or "http://localhost:80",
		method = method or "GET"
	}

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			if HttpRequest[v] ~= nil then
				return HttpRequest[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

local string_format = string.format

function HttpRequest:ToString()
	-- todo headers, body
	return string_format("%s %s HTTP/1.1\n\n", self.method, self.url)
end

return HttpRequest