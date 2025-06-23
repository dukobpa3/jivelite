--[[
=head1 NAME

jive.utils.icon - Material Design Icon font utilities

=head1 DESCRIPTION

A utility module for easy access to Material Design icon fonts and Unicode codes.

=head1 SYNOPSIS

 -- Get the Unicode character for an icon
 local iconCode = icon.getCode("play_arrow")

 -- Get the regular icon font
 local regularIconFont = icon.regularFont(24)

 -- Use in a text widget
 local myLabel = Label("text", iconCode)
 myLabel:setStyle({ font = regularIconFont })

=cut
--]]

local log = require("jive.utils.log").logger("jive.utils.icon")
local Font = require("jive.ui.Font")

local M = {}

-- Icon font paths
local ICON_FONT_PATH = "icons/"
local ICON_FONTS = {
	regular = "Material_Icons/MaterialIcons-Regular.ttf",
	outlined = "Material_Icons_Outlined/MaterialIconsOutlined-Regular.otf",
	round = "Material_Icons_Round/MaterialIconsRound-Regular.otf",
	sharp = "Material_Icons_Sharp/MaterialIconsSharp-Regular.otf",
	two_tone = "Material_Icons_Two_Tone/MaterialIconsTwoTone-Regular.otf"
}

-- Material Design Icons Unicode mapping
M.icons = {
	-- Media controls
	play_arrow = "\u{e037}",
	pause = "\u{e034}",
	stop = "\u{e047}",
	skip_next = "\u{e044}",
	skip_previous = "\u{e045}",
	fast_forward = "\u{e01f}",
	fast_rewind = "\u{e020}",
	replay = "\u{e042}",
	shuffle = "\u{e043}",
	repeat_icon = "\u{e040}",
	volume_up = "\u{e050}",
	volume_down = "\u{e04d}",
	volume_off = "\u{e04f}",
	volume_mute = "\u{e04e}",
	
	-- Navigation
	home = "\u{e88a}",
	menu = "\u{e5d2}",
	close = "\u{e5cd}",
	arrow_back = "\u{e5c4}",
	arrow_forward = "\u{e5c8}",
	arrow_upward = "\u{e5c7}",
	arrow_downward = "\u{e5c5}",
	expand_more = "\u{e5cf}",
	expand_less = "\u{e5ce}",
	chevron_left = "\u{e5cb}",
	chevron_right = "\u{e5cc}",
	
	-- Common actions
	search = "\u{e8b6}",
	settings = "\u{e8b8}",
	account_circle = "\u{e853}",
	add = "\u{e145}",
	remove = "\u{e15b}",
	edit = "\u{e3c9}",
	delete = "\u{e872}",
	save = "\u{e161}",
	cancel = "\u{e5c9}",
	check = "\u{e5ca}",
	clear = "\u{e14c}",
	
	-- Social
	favorite = "\u{e87d}",
	star = "\u{e838}",
	heart = "\u{e87d}",
	thumb_up = "\u{e8dc}",
	thumb_down = "\u{e8db}",
	like = "\u{e8dc}",
	dislike = "\u{e8db}",
	
	-- Communication
	phone = "\u{e0cd}",
	message = "\u{e0c9}",
	notifications = "\u{e7f4}",
	email = "\u{e0e1}",
	mail = "\u{e0e1}",
	chat = "\u{e0b7}",
	call = "\u{e0b0}",
	
	-- File operations
	download = "\u{e2c4}",
	upload = "\u{e2c6}",
	share = "\u{e80d}",
	print = "\u{e8ad}",
	file_download = "\u{e2c4}",
	file_upload = "\u{e2c6}",
	
	-- System
	wifi = "\u{e63e}",
	bluetooth = "\u{e1a7}",
	gps_fixed = "\u{e1b3}",
	location_on = "\u{e55f}",
	location_off = "\u{e55e}",
	brightness_high = "\u{e1ac}",
	brightness_low = "\u{e1ad}",
	contrast = "\u{e3b1}",
	
	-- Time and date
	calendar_today = "\u{e935}",
	schedule = "\u{e8b5}",
	access_time = "\u{e192}",
	timer = "\u{e425}",
	alarm = "\u{e855}",
	
	-- Files and media
	folder = "\u{e2c7}",
	file = "\u{e24d}",
	image = "\u{e3f4}",
	video_library = "\u{e04a}",
	music_note = "\u{e405}",
	photo = "\u{e410}",
	movie = "\u{e02c}",
	
	-- UI elements
	refresh = "\u{e5d5}",
	more_vert = "\u{e5d4}",
	more_horiz = "\u{e5d3}",
	drag_handle = "\u{e25d}",
	visibility = "\u{e8f4}",
	visibility_off = "\u{e8f5}",
	lock = "\u{e897}",
	lock_open = "\u{e898}",
	
	-- Status
	error = "\u{e000}",
	warning = "\u{e002}",
	info = "\u{e88e}",
	check_circle = "\u{e86c}",
	cancel_circle = "\u{e14c}",
	help = "\u{e887}",
	
	-- Direction
	north = "\u{e160}",
	south = "\u{e15e}",
	east = "\u{e15d}",
	west = "\u{e15f}",
	
	-- Other common
	apps = "\u{e5c3}",
	dashboard = "\u{e871}",
	person = "\u{e7fd}",
	group = "\u{e7ef}",
	work = "\u{e8f9}",

	school = "\u{e80c}",
	store = "\u{e8d1}",
	restaurant = "\u{e56c}",
	hotel = "\u{e53a}",
	flight = "\u{e539}",
	car = "\u{e531}",
	train = "\u{e570}",
	bus = "\u{e530}",
	bike = "\u{e52f}",
	walk = "\u{e536}"
}

-- Cache for loaded icon fonts
local iconFontCache = {}

local function _getFont(style, size)
	style = style or "regular"
	size = size or 24
	
	local cacheKey = style .. "_" .. size
	
	if not iconFontCache[cacheKey] then
		local fontPath = ICON_FONTS[style]
		if not fontPath then
			log:warn("Unknown icon style: ", style, ". Using regular style.")
			style = "regular"
			fontPath = ICON_FONTS.regular
		end
		
		iconFontCache[cacheKey] = Font:load(ICON_FONT_PATH .. fontPath, size)
		log:debug("Loaded icon font: ", style, " size: ", size)
	end
	
	return iconFontCache[cacheKey]
end

--[[
=head2 icon.font(size)

Gets the default (regular) icon font.
I<size> is the font size.

=cut
--]]
function M.font(size)
	return _getFont("regular", size)
end

--[[
=head2 icon.regularFont(size)

Gets the regular icon font.
I<size> is the font size.

=cut
--]]
function M.regularFont(size)
	return _getFont("regular", size)
end

--[[
=head2 icon.outlinedFont(size)

Gets the outlined icon font.
I<size> is the font size.

=cut
--]]
function M.outlinedFont(size)
	return _getFont("outlined", size)
end

--[[
=head2 icon.roundFont(size)

Gets the round icon font.
I<size> is the font size.

=cut
--]]
function M.roundFont(size)
	return _getFont("round", size)
end

--[[
=head2 icon.sharpFont(size)

Gets the sharp icon font.
I<size> is the font size.

=cut
--]]
function M.sharpFont(size)
	return _getFont("sharp", size)
end

--[[
=head2 icon.twoToneFont(size)

Gets the two-tone icon font.
I<size> is the font size.

=cut
--]]
function M.twoToneFont(size)
	return _getFont("two_tone", size)
end


--[[
=head2 icon.getAvailableIcons()

Returns a table with all available icon names.

=cut
--]]
function M.getAvailableIcons()
	local icons = {}
	for iconName, _ in pairs(M.icons) do
		table.insert(icons, iconName)
	end
	table.sort(icons)
	return icons
end

--[[
=head2 icon.clearCache()

Clears the icon font cache to free memory.

=cut
--]]
function M.clearCache()
	iconFontCache = {}
	log:debug("Icon font cache cleared")
end

return M