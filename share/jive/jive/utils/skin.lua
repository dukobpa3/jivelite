local log = require("jive.utils.log").logger("jive.utils.skin")
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

local function _buildTileKey(tileTable)
	local key = ""
	for i = 1, #tileTable do
		local element = tileTable[i] or "NIL"
		key = key .. element .. "&"
	end

	return key
end

function M.loadTile(cache, tileTable)
	if not tileTable then
		return nil
	end

	local key = _buildTileKey(tileTable)


	if not cache[key] then
		cache[key] = Tile:loadTiles(tileTable)
	end

	return cache[key]
end


function M.loadHTile(cache, tileTable)
	if not tileTable then
		return nil
	end

	local key = _buildTileKey(tileTable)

	if not cache[key] then
		cache[key] = Tile:loadHTiles(tileTable)
	end

	return cache[key]
end


function M.loadVTile(cache, tileTable)
	if not tileTable then
		return nil
	end

	local key = _buildTileKey(tileTable)

	if not cache[key] then
		cache[key] = Tile:loadVTiles(tileTable)
	end

	return cache[key]
end


function M.loadImageTile(file)
	if not file then
		return nil
	end

	return Tile:loadImage(file)
end


--[[
Vector Drawing Functions

These functions provide a way to programmatically draw UI elements like backgrounds
and buttons instead of using pre-made image files. This is the foundation for
creating a DPI-aware UI.

All `draw*` functions accept a `style` table with the following structure:

@param style (table) A table describing the appearance of the drawable element.
    .w (number)                 - Required. Width of the element.
    .h (number)                 - Required. Height of the element.
    .backgroundColor (table)    - Color for a solid fill (e.g., { r=255, g=0, b=0, a=255 }).
    .borderColor (table)        - Color of the border.
    .borderWidth (number)       - Width of the border in pixels.
    .cornerRadius (number|table) - (Reserved for future use) Radius for rounded corners.
                                  Can be a single number to apply to all corners,
                                  or a table `{ topLeft, topRight, bottomRight, bottomLeft }`
                                  for individual corner control.
    .gradient (table)           - A table describing a color gradient. If present,
                                  it overrides `backgroundColor`.
        .startColor (table)     - The starting color of the gradient (e.g., { r=255, g=0, b=0 }).
        .endColor (table)       - The ending color of the gradient.
        .orientation (string)   - 'vertical' (default) or 'horizontal'.
        .step (number)          - The thickness of each gradient line in pixels
                                  (default is 1). Higher values can improve
                                  performance on slower devices.


local function _packColor(c)
	if not c then return nil end
	-- Use default alpha if not provided
	local r = c.r or 0
	local g = c.g or 0
	local b = c.b or 0
	local a = c.a or 255
	return bit.bor(bit.lshift(r, 24), bit.lshift(g, 16), bit.lshift(b, 8), a)
end

local function _buildDrawKey(style)
	-- Simple serialization of the style table to create a cache key
	local key = ""
	if not style then return "" end

	-- Sort keys to ensure consistent order
	local keys = {}
	for k in pairs(style) do table.insert(keys, k) end
	table.sort(keys)

	for _, k in ipairs(keys) do
		local v = style[k]
		if type(v) == 'table' then
			-- poor man's deep serialization
			key = key .. k .. "={" .. _buildDrawKey(v) .. "}&"
		else
			key = key .. k .. "=" .. tostring(v) .. "&"
		end
	end
	return key
end

local function _drawGradient(surface, w, h, style)
	local startColor = style.gradient.startColor
	local endColor = style.gradient.endColor
	local orientation = style.gradient.orientation or 'vertical'
	local step = style.gradient.step or 1

	local r1, g1, b1, a1 = startColor.r or 0, startColor.g or 0, startColor.b or 0, startColor.a or 255
	local r2, g2, b2, a2 = endColor.r or 0, endColor.g or 0, endColor.b or 0, endColor.a or 255

	if orientation == 'vertical' then
		for y = 0, h, step do
			local p = y / h
			local r = math.floor(r1 * (1 - p) + r2 * p)
			local g = math.floor(g1 * (1 - p) + g2 * p)
			local b = math.floor(b1 * (1 - p) + b2 * p)
			local a = math.floor(a1 * (1 - p) + a2 * p)
			local col = bit.bor(bit.lshift(r, 24), bit.lshift(g, 16), bit.lshift(b, 8), a)
			Surface.boxColor(surface, 0, y, w, y + step, col)
		end
	else -- horizontal
		for x = 0, w, step do
			local p = x / w
			local r = math.floor(r1 * (1 - p) + r2 * p)
			local g = math.floor(g1 * (1 - p) + g2 * p)
			local b = math.floor(b1 * (1 - p) + b2 * p)
			local a = math.floor(a1 * (1 - p) + a2 * p)
			local col = bit.bor(bit.lshift(r, 24), bit.lshift(g, 16), bit.lshift(b, 8), a)
			Surface.boxColor(surface, x, 0, x + step, h, col)
		end
	end
end

local function _draw(style)
	if not style or not style.w or not style.h then
		return nil
	end

	local w, h = style.w, style.h
	local srf = Surface:newRGBA(w, h)

	-- Normalize cornerRadius to a table with all four values
	local cr = style.cornerRadius
	local radii
	if cr and type(cr) == 'table' then
		radii = { 
			topLeft = cr.topLeft or 0,
			topRight = cr.topRight or 0,
			bottomRight = cr.bottomRight or 0,
			bottomLeft = cr.bottomLeft or 0,
		}
	elseif cr and type(cr) == 'number' and cr > 0 then
		radii = { topLeft = cr, topRight = cr, bottomRight = cr, bottomLeft = cr }
	end

	-- Main drawing logic
	if not radii or (radii.topLeft <= 0 and radii.topRight <= 0 and radii.bottomLeft <= 0 and radii.bottomRight <= 0) then
		-- Fallback to simple, fast drawing for non-rounded rectangles
		if style.gradient then
			_drawGradient(srf, w, h, style)
		elseif style.backgroundColor then
			Surface.boxColor(srf, 0, 0, w, h, _packColor(style.backgroundColor))
		end
	else
		-- Advanced drawing for rounded rectangles
		-- NOTE: This currently supports solid colors and VERTICAL gradients.
		-- Horizontal gradients would require a different loop (iterating by x and drawing vlines).

		for y = 0, h - 1 do
			local startX, endX = 0, w

			-- Calculate left edge based on corner radius
			if y < radii.topLeft then
				local r = radii.topLeft
				startX = r - math.sqrt(r*r - (r - y - 0.5)^2)
			elseif y >= h - radii.bottomLeft then
				local r = radii.bottomLeft
				local y_rel = y - (h - r)
				startX = r - math.sqrt(r*r - (y_rel + 0.5)^2)
			end

			-- Calculate right edge based on corner radius
			if y < radii.topRight then
				local r = radii.topRight
				endX = w - (r - math.sqrt(r*r - (r - y - 0.5)^2))
			elseif y >= h - radii.bottomRight then
				local r = radii.bottomRight
				local y_rel = y - (h - r)
				endX = w - (r - math.sqrt(r*r - (y_rel + 0.5)^2))
			end
			
			startX = math.floor(startX)
			endX = math.ceil(endX)

			-- Determine color for the current line
			local color
			if style.gradient and style.gradient.orientation ~= 'horizontal' then
				local p = y / h

				local sc = style.gradient.startColor
				local ec = style.gradient.endColor

				local r1 = sc.r or 0
				local g1 = sc.g or 0
				local b1 = sc.b or 0
				local a1 = sc.a or 255

				local r2 = ec.r or 0
				local g2 = ec.g or 0
				local b2 = ec.b or 0
				local a2 = ec.a or 255
				
				local r = math.floor(r1 * (1 - p) + r2 * p)
				local g = math.floor(g1 * (1 - p) + g2 * p)
				local b = math.floor(b1 * (1 - p) + b2 * p)
				local a = math.floor(a1 * (1 - p) + a2 * p)

				color = bit.bor(bit.lshift(r, 24), bit.lshift(g, 16), bit.lshift(b, 8), a)
			else
				color = _packColor(style.backgroundColor)
			end

			-- Draw the horizontal line if it has a valid color and width
			if color and startX < endX then
				Surface.hlineColor(srf, startX, endX - 1, y, color)
			end
		end
	end


	-- Draw border (TODO: This needs to be updated to support rounded corners)
	if style.borderColor and style.borderWidth and style.borderWidth > 0 then
		-- The current implementation will draw a sharp rectangle border over the rounded shape.
		local borderColor = _packColor(style.borderColor)
		if borderColor then
			for i=1,style.borderWidth do
				Surface.rectangleColor(srf, i-1, i-1, w-i, h-i, borderColor)
			end
		end
	end

	-- In the future, we will handle cornerRadius here, probably by calling
	-- a C function for roundedBox and filling the outer corners with transparency.

	return srf
end


function M.drawTile(cache, style)
	if not style then return nil end

	local key = _buildDrawKey(style)
	if cache and cache[key] then
		return cache[key]
	end

	local tile = _draw(style)

	if cache then
		cache[key] = tile
	end
	return tile
end

function M.drawHTile(cache, style)
	-- For now, HTile is the same as a normal Tile
	return M.drawTile(cache, style)
end

function M.drawVTile(cache, style)
	-- For now, VTile is the same as a normal Tile
	return M.drawTile(cache, style)
end

-- define a local function to make it easier to create icons.
]]

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