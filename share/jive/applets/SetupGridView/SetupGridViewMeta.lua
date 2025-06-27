--[[
=head1 NAME

applets.SetupGridView.SetupGridViewMeta - Grid View Settings

=head1 DESCRIPTION

This applet allows users to configure which content types use grid view vs list view.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

=cut
--]]

local oo            = require("loop.simple")
local AppletMeta    = require("jive.AppletMeta")

local appletManager = appletManager
local JiveMain      = jiveMain

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(self)
	log:debug("SetupGridView: jiveVersion")
	return 1, 1
end

function defaultSettings(self)
	log:debug("SetupGridView: defaultSettings")
	return {
		home = false,
		albums = false,      -- Grid view for albums
		artists = false,    -- List view for artists
		playlists = false,  -- List view for playlists
		genres = false,     -- List view for genres
		years = false,      -- List view for years
		newMusic = false,   -- List view for new music
		search = false,     -- List view for search results
	}
end

function registerApplet(self)
	log:debug("SetupGridView: registerApplet")
	
	JiveMain:addItem(self:menuItem("appletSetupGridView", "screenSettings", "SETUP_GRID_VIEW", function(applet, ...) applet:settingsShow(...) end))
	log:debug("SetupGridView: registerApplet: addItem")
	self:registerService("getGridViewSettings")
	self:registerService("shouldUseGridView")
	log:debug("SetupGridView: registerApplet: registerService")
end

function configureApplet(self)
	log:debug("SetupGridView: configureApplet")
	local settings = self:getSettings()
	log:debug("SetupGridView: settings", settings)
	-- TODO: do we need to do any?
end

--[[

=head1 LICENSE

Copyright 2024 Logitech. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]] 