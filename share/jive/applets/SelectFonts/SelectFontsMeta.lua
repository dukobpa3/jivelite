
--[[
=head1 NAME

applets.SelectSkin.SelectSkinMeta - Select SqueezePlay skin

=head1 DESCRIPTION

See L<applets.SelectSkin.SelectSkinApplet>.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

=cut
--]]


local oo            = require("loop.simple")

local AppletMeta    = require("jive.AppletMeta")
local FontM         = require("jive.ui.FontM")

local jiveMain      = jiveMain
local jnt           = jnt

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(meta)
	return 1, 1
end


function defaultSettings(meta)
	return {
		regular = "FreeSans",
		bold = "FreeSansBold",
		name = "FreeSans"
	}
end


function registerApplet(meta)
	jiveMain:addItem(meta:menuItem('appletSelectFonts', 'screenSettings', 'SELECT_FONTS', function(applet, ...) applet:selectFontsEntryPoint(...) end))
	meta:registerService("selectFontStartup")

	jnt:subscribe(meta)
end


function configureApplet(meta)
	local settings = meta:getSettings()
	FontM:setupFonts(settings['regular'], settings['bold'])
end


--[[

=head1 LICENSE

Copyright 2010 Logitech, 2024 Blaise Dias. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]]

