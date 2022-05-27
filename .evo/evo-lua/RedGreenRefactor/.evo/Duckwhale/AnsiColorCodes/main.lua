local AnsiConsoleColors = {}

local COLOR_START_SEQUENCE = "\27["
local RESET_SEQUENCE = "\27[0;0m"
local COLOR_CODE_GREEN = "0;32m"
local COLOR_CODE_GRAY = "1;30m"
local COLOR_CODE_WHITE = "1;37m"
local COLOR_CODE_RED = "0;31m"
local COLOR_CODE_CYAN = "0;96m"
local COLOR_CODE_YELLOW = "0;33m"
local COLOR_CODE_RED_BACKGROUND_BRIGHT = "0;101m"
local COLOR_CODE_GREEN_BACKGROUND = "0;42m"

function AnsiConsoleColors:Red(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_RED .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:Yellow(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_YELLOW .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:Cyan(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_CYAN .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:Gray(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_GRAY .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:White(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_WHITE .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:GreenBackground(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_GREEN_BACKGROUND .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:BrightRedBackground(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_RED_BACKGROUND_BRIGHT .. text .. RESET_SEQUENCE
end

function AnsiConsoleColors:Green(text)
	return COLOR_START_SEQUENCE .. COLOR_CODE_GREEN .. text .. RESET_SEQUENCE
end

return AnsiConsoleColors
