--[[
=head1 NAME

jive.ui.Dpi

=head1 DESCRIPTION

=cut
--]]

local tonumber = tonumber

local oo = require("loop.base")
local os = require("os")
local math = require("math")

module(..., oo.class)

local _dpi = tonumber(os.getenv('JL_DPI') or 560)
local _baseDpi = 160
local _fontScale = 1.0
local _scale = _dpi / _baseDpi

function dp(self, value)
	return math.floor(value * _scale + 0.5)
end

function sp(self, value)
	return math.floor(value * _scale * _fontScale + 0.5)
end

function setFontScale(self, scale)
	_fontScale = scale or 1.0
end

function getDpi(self)
	return _dpi
end

function getScale(self)
	return _scale
end
