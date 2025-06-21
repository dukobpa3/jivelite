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