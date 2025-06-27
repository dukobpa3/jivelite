
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

local JiveMain      = jiveMain

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(self)
	return 1, 1
end


function defaultSettings(self)
	return {
		regular = "FreeSans",
		bold = "FreeSansBold",
		name = "FreeSans"
	}
end


function registerApplet(self)
	self:registerService("getFontsSettings")

	JiveMain:addItem(self:menuItem('appletSetupFonts', 'screenSettings', 'SETUP_FONTS', function(applet, ...) applet:settingsShow(...) end))
end


function configureApplet(self)
	local settings = self:getSettings()
	FontM:setupFonts(settings['regular'], settings['bold'])
end


--[[

=head1 LICENSE

Copyright 2010 Logitech, 2024 Blaise Dias. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]]

