--[[
=head1 NAME

applets.SetupGridView.SetupGridViewApplet - Grid View Settings

=head1 DESCRIPTION

This applet allows users to configure which content types use grid view vs list view.

=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>. 
SetupGridViewApplet overrides the following methods:

=cut
--]]

-- stuff we use
local pairs, type, string = pairs, type, string

local table           = require("table")

local oo              = require("loop.simple")

local Applet          = require("jive.Applet")
local RadioButton     = require("jive.ui.RadioButton")
local RadioGroup      = require("jive.ui.RadioGroup")
local Checkbox        = require("jive.ui.Checkbox")
local System          = require("jive.System")
local debug           = require("jive.utils.debug")

local SimpleMenu      = require("jive.ui.SimpleMenu")
local Window          = require("jive.ui.Window")
local Framework       = require("jive.ui.Framework")

local appletManager   = appletManager
local jiveMain        = jiveMain

module(..., Framework.constants)
oo.class(_M, Applet)

local CONTENT_TYPES = {
	albums = {
		patterns = {"albums", "album"},
		description = "GRID_VIEW_ALBUMS"
	},
	artists = {
		patterns = {"artists", "artist"},
		description = "GRID_VIEW_ARTISTS"
	},
	playlists = {
		patterns = {"playlists", "playlist"},
		description = "GRID_VIEW_PLAYLISTS"
	},
	genres = {
		patterns = {"genres", "genre"},
		description = "GRID_VIEW_GENRES"
	},
	years = {
		patterns = {"years", "year"},
		description = "GRID_VIEW_YEARS"
	},
	newMusic = {
		patterns = {"new music", "newmusic"},
		description = "GRID_VIEW_NEW_MUSIC"
	},
	search = {
		patterns = {"search"},
		description = "GRID_VIEW_SEARCH"
	}
}

function settingsShow(self, menuItem)
	log:debug("SetupGridView: settingsShow")
	local window = Window("text_list", menuItem.text, 'settingstitle')
	local menu = SimpleMenu("menu")

	local settings = self:getSettings()
	
	-- Add checkboxes for each content type
	for contentType, config in pairs(CONTENT_TYPES) do
		menu:addItem({
			text = self:string(config.description),
			style = 'item_choice',
			check = Checkbox(
				"checkbox",
				function(_, checked)
					log:info("SetupGridView: ", contentType, " set to ", checked)
					settings[contentType] = checked
					self:storeSettings()
					jiveMain:reloadSkin()
				end,
				settings[contentType] or false
			)
		})
	end

	window:addWidget(menu)
	self:tieAndShowWindow(window)
	return window
end

-- Service method to get current grid view settings
function getGridViewSettings(self)
	log:debug("SetupGridView: getGridViewSettings")
	return self:getSettings()
end

-- Service method to determine if grid view should be used for given content
function shouldUseGridView(self, item, windowStyle)
	log:debug("SetupGridView: shouldUseGridView")
	-- Only apply to icon_list windows
	if windowStyle ~= 'icon_list' then
		return false
	end
	
	-- Don't override play_list
	if windowStyle == 'play_list' then
		return false
	end
	
	local settings = self:getSettings()
	local itemText = (item and item.text or ""):lower()
	local itemType = (item and item.type or ""):lower()
	
	-- Check each content type
	for contentType, config in pairs(CONTENT_TYPES) do
		if settings[contentType] then
			-- Check patterns
			for _, pattern in ipairs(config.patterns) do
				if string.find(itemText, pattern, 1, true) or string.find(itemType, pattern, 1, true) then
					log:debug("SetupGridView: Using grid view for ", contentType, " (matched: ", pattern, ")")
					return true
				end
			end
		end
	end
	
	return false
end

--[[

=head1 LICENSE

Copyright 2024 Logitech. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]] 