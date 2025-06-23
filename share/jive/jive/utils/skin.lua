local log = require("jive.utils.log").logger("piCorePlayer")
local Surface = require("jive.ui.Surface")
local Tile = require("jive.ui.Tile")
local FontM = require("jive.ui.FontM")

local EVENT_ACTION           = jive.ui.EVENT_ACTION
local EVENT_CONSUME          = jive.ui.EVENT_CONSUME
local EVENT_WINDOW_POP       = jive.ui.EVENT_WINDOW_POP
local LAYER_FRAME            = jive.ui.LAYER_FRAME
local LAYER_CONTENT_ON_STAGE = jive.ui.LAYER_CONTENT_ON_STAGE
local LAYER_TITLE            = jive.ui.LAYER_TITLE

local LAYOUT_NORTH           = jive.ui.LAYOUT_NORTH
local LAYOUT_EAST            = jive.ui.LAYOUT_EAST
local LAYOUT_SOUTH           = jive.ui.LAYOUT_SOUTH
local LAYOUT_WEST            = jive.ui.LAYOUT_WEST
local LAYOUT_CENTER          = jive.ui.LAYOUT_CENTER
local LAYOUT_NONE            = jive.ui.LAYOUT_NONE

local WH_FILL                = jive.ui.WH_FILL

local M = {}

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

function M.loadImage(file)
	return Surface:loadImage(file)
end

function M.icon(x, y, img)
	return {
		x = x,
		y = y,
		img = M.loadImage(img),
		layer = LAYER_FRAME,
		position = LAYOUT_SOUTH,
	}
end

function M.buildTileKey(tileTable)
	local key = ""
	for i = 1, #tileTable do
		local element = tileTable[i] or "NIL"
		key = key .. element .. "&"
	end

	return key
end

function M.loadTile(tiles, tileTable)
	if not tileTable then
		return nil
	end

	local key = M.buildTileKey(tileTable)


	if not tiles[key] then
		tiles[key] = Tile:loadTiles(tileTable)
	end

	return tiles[key]
end


function M.loadHTile(hTiles, tileTable)
	if not tileTable then
		return nil
	end

	local key = M.buildTileKey(tileTable)

	if not hTiles[key] then
		hTiles[key] = Tile:loadHTiles(tileTable)
	end

	return hTiles[key]
end


function M.loadVTile(vTiles, tileTable)
	if not tileTable then
		return nil
	end

	local key = M.buildTileKey(tileTable)

	if not vTiles[key] then
		vTiles[key] = Tile:loadVTiles(tileTable)
	end

	return vTiles[key]
end


function M.loadImageTile(file)
	if not file then
		return nil
	end

	return Tile:loadImage(file)
end


-- define a local function to make it easier to create icons.


-- define a local function that makes it easier to set fonts
function M.font(fontSize)
	return FontM:regularFont(fontSize)
end

-- define a local function that makes it easier to set bold fonts
function M.boldfont(fontSize)
	return FontM:boldFont(fontSize)
end

function M.iconFont(fontSize)
	return FontM:iconFont(fontSize)
end

-- defines a new style that inherrits from an existing style
function M.uses(parent, value)
	if parent == nil then
		log:warn("nil parent in _uses at:\n", debug.traceback())
	end
	local style = {}
	setmetatable(style, { __index = parent })
	for k,v in pairs(value or {}) do
		if type(v) == "table" and type(parent[k]) == "table" then
			-- recursively inherrit from parent style
			style[k] = M.uses(parent[k], v)
		else
			style[k] = v
		end
	end

	return style
end

return M