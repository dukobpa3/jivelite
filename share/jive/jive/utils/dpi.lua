--[[
=head1 NAME

jive.utils.dpi

=head1 DESCRIPTION

=cut
--]]

local tonumber, floor = tonumber, math.floor
local os = require("os")

local M = {}
M._dpi = tonumber(os.getenv('JL_DPI') or 560)
M._baseDpi = 160
M._scale = M._dpi / M._baseDpi
M._fontScale = 1.0

function M.dp(value)
	return floor(value * M._scale + 0.5)
end

function M.sp(value)
	return floor(value * M._scale * M._fontScale + 0.5)
end

function M.setFontScale(scale)
	M._fontScale = scale or 1.0
end

function M.getDpi()
	return M._dpi
end

function M.getScale()
	return M._scale
end

return M
