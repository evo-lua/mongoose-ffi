local CountedString = {}

local ffi = require("ffi")

local tonumber = tonumber
local string_char = string.char
local table_concat = table.concat

function CountedString.ToLuaString(countedString)
	local stringLength = tonumber(countedString.len)

	-- if stringLength == 0 then return "" end

	local charBuffer = ffi.cast("unsigned const char*", countedString.ptr) -- it's signed, but string.char can't deal with that
	-- print(stringLength, charBuffer)
	-- There's probably a way to do this without allocations, but the returned data should be a Lua string (usability)
	local characters = {}
	for index = 0, stringLength - 1, 1 do
		-- print("index", index)
		-- print("charAt[index]", charBuffer[index])
		-- print("charAt", string_char(charBuffer[index]))

		-- tbd can this fall flat on its face if they're unicode strings? probably not if Lua just represents them differently...
		characters[#characters+1] = string_char(charBuffer[index])
	end
	local luaString = table_concat(characters, "")
	-- print("luaString", luaString)
	return luaString
end

return CountedString