local HttpMessage = {}

local CountedString = import("./CountedString.lua")

function HttpMessage:Construct(httpMessageStruct)

	local instance = {
		method = CountedString.ToLuaString(httpMessageStruct.method),
		url = CountedString.ToLuaString(httpMessageStruct.uri),
		queryString = CountedString.ToLuaString(httpMessageStruct.query),
		protocolString = CountedString.ToLuaString(httpMessageStruct.proto),
		headers = {},
		body = CountedString.ToLuaString(httpMessageStruct.body),
		message = CountedString.ToLuaString(httpMessageStruct.message),
		cdata = httpMessageStruct, -- tbd freed when?
	}

	local NUM_HEADERS = 40 -- Hardcoded define in mongoose.h (default value)
	for headerIndex = 0, NUM_HEADERS - 1, 1 do
		local header = httpMessageStruct.headers[headerIndex]
		local key = CountedString.ToLuaString(header.name)
		local value = CountedString.ToLuaString(header.value)

		if key ~= "" and value ~= "" then
			DEBUG("Processing HTTP header " .. headerIndex, key, value)
			instance.headers[key] = value
		end
	end

	local inheritanceLookupMetatable = {
		__index = function(t, v)
			if HttpMessage[v] ~= nil then
				return HttpMessage[v]
			else
				return rawget(t, v)
			end
		end
	}

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

function HttpMessage:ToString()
	return self.message -- TBD obsolete?
end

return HttpMessage