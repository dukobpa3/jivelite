--[[
=head1 NAME

applets.JogglerSkin.JogglerSkinApplet

=head1 DESCRIPTION


This applet implements an 800x480 resolution skin.

Redesigned from WQVGAsmallSkin by Andy Davison.

Built upon the work of 3guk, Tarkan Akdam and Justblair.

Version 1.10 (10th April 2012)
birdslikewires.co.uk


=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>. 
SqueezeboxSkin overrides the following methods:

=cut
--]]


-- stuff we use
local ipairs, pairs, setmetatable, type, tostring, tonumber =
	ipairs, pairs, setmetatable, type, tostring, tonumber

local oo                     = require("loop.simple")
local string                 = require("jive.utils.string")
local math                   = require("math")
local os                     = require("os")
local Applet                 = require("jive.Applet")
local Audio                  = require("jive.ui.Audio")
local Checkbox               = require("jive.ui.Checkbox")
local Framework              = require("jive.ui.Framework")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Tile                   = require("jive.ui.Tile")
local Window                 = require("jive.ui.Window")

local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")
local autotable              = require("jive.utils.autotable")

local log                    = require("jive.utils.log").logger("applet.DpiSkin")
local DpiUtils               = require("jive.skin.dpi")
local SkinUtils              = require("jive.skin.skin")

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

local jiveMain               = jiveMain
local appletManager          = appletManager


module(..., Framework.constants)
oo.class(_M, Applet)

-- skin functions
local _loadImage =  SkinUtils.loadImage
local _loadTile =  SkinUtils.loadTile
local _loadHTile =  SkinUtils.loadHTile
local _loadVTile =  SkinUtils.loadVTile
local _loadImageTile =  SkinUtils.loadImageTile
local _icon =  SkinUtils.icon
local _font =  SkinUtils.font
local _boldfont =  SkinUtils.boldfont
local _iconFont =  SkinUtils.iconFont
local _uses =  SkinUtils.uses

local _dp = DpiUtils.dp
local _sp = DpiUtils.sp

local _icons = SkinUtils.icons

-- Define useful variables for this skin
local imgpath = "applets/DpiSkin/images/"



local tbButtons = { 'rew', 'play', 'fwd', 'repeatMode', 'shuffleMode', 'volDown', 'volSlider', 'volUp' }

function init(self)
	self.images = {}

	self.imageTiles = {}
	self.hTiles = {}
	self.vTiles = {}
	self.tiles = {}

	jiveMain:addItem(self:buttonSettingsMenuItem())
end


function param(self)
	local screenWidth, screenHeight = Framework:getScreenSize()
	local maxArtwork = tostring(screenHeight) .. 'x' .. tostring(screenHeight)
	local midArtwork = tostring(screenHeight - _dp(180)) .. 'x' .. tostring(screenHeight - _dp(180))
	
	return {
		THUMB_SIZE = _dp(40),
		THUMB_SIZE_MENU = _dp(40),
		NOWPLAYING_MENU = false,
		-- NOWPLAYING_TRACKINFO_LINES used in assisting scroll behavior animation on NP
		-- 3 is for a three line track, artist, and album (e.g., SBtouch)
		-- 2 is for a two line track, artist+album (e.g., SBradio, SBcontroller)
		NOWPLAYING_TRACKINFO_LINES = 3,
		POPUP_THUMB_SIZE = _dp(120),
		piCorePlayerStyle = 'hm_settings_pcp',
		nowPlayingScreenStyles = {
			-- every skin needs to start off with a nowplaying style
			{
				style = 'nowplaying', 
				artworkSize = midArtwork,
				text = self:string("ART_AND_TEXT"),
			},
			{
				style = 'nowplaying_large_art',
				artworkSize = maxArtwork,
				titleXofYonly = true,
				text = self:string("LARGE_ART_AND_TEXT"),
			},
			{
				style = 'nowplaying_art_only',
				artworkSize = maxArtwork,
				suppressTitlebar = 1,
				text = self:string("ART_ONLY"),
			},
			{
				style = 'nowplaying_text_only',
				artworkSize = midArtwork,
				text = self:string("TEXT_ONLY"),
			},
			{
				style = 'nowplaying_spectrum_text',
				artworkSize = midArtwork,
				localPlayerOnly = 1,
				text = self:string("SPECTRUM_ANALYZER"),
			},
			{
				style = 'nowplaying_vuanalog_text',
				artworkSize = midArtwork,
				localPlayerOnly = 1,
				text = self:string("ANALOG_VU_METER"),
			},
		},
	}
end



-- skin
-- The meta arranges for this to be called to skin the interface.
function skin(self, s, reload, useDefaultSize, w, h)
	if (not w) then w = 800 end
	if (not h) then h = 480 end

	--init lastInputType so selected item style is not shown on skin load
	Framework.mostRecentInputType = "mouse"

	-- skin
	local thisSkin = 'touch'
	local skinSuffix = "_" .. thisSkin .. ".png"

	-- Font Size Constants
	local FONT_SIZE_XXL = _sp(120) -- huge
	local FONT_SIZE_XL = _sp(60) -- textinput
	local FONT_SIZE_L = _sp(48) -- keyboard
	local FONT_SIZE_M = _sp(32) -- track, slider heading
	local FONT_SIZE_S = _sp(24) -- header, large text, menus
	local FONT_SIZE_XS = _sp(18) -- base, medium, small
	local FONT_SIZE_XXS = _sp(14) -- xsmall

	-- Gap Constants
	local GAP_1 = _dp(1)
	local GAP_2 = _dp(2)
	local GAP_4 = _dp(4)
	local GAP_5 = _dp(5)
	local GAP_6 = _dp(6)
	local GAP_7 = _dp(7)
	local GAP_8 = _dp(8)
	local GAP_9 = _dp(9)
	local GAP_10 = _dp(10)
	local GAP_11 = _dp(11)
	local GAP_12 = _dp(12)
	local GAP_13 = _dp(13)
	local GAP_14 = _dp(14)
	local GAP_15 = _dp(15)
	local GAP_16 = _dp(16)
	local GAP_17 = _dp(17)
	local GAP_18 = _dp(18)
	local GAP_20 = _dp(20)
	local GAP_22 = _dp(22)
	local GAP_24 = _dp(24)
	local GAP_28 = _dp(28)
	local GAP_34 = _dp(34)
	local GAP_40 = _dp(40)
	local GAP_50 = _dp(50)
	local GAP_90 = _dp(90)
	local GAP_100 = _dp(100)
	local GAP_160 = _dp(160)
	local GAP_200 = _dp(200)

	-- Images and Tiles
	local inputTitleBox           = _loadImageTile(imgpath .. "Titlebar/titlebar.png" )
	local cancelButton            = _loadImageTile(imgpath .. "Icons/icon_close_button_tb.png")
	local homeButton              = _loadImageTile(imgpath .. "Icons/icon_home_button_tb.png")
	local helpButton              = _loadImageTile(imgpath .. "Icons/icon_help_button_tb.png")
	local powerButton             = _loadImageTile(imgpath .. "Icons/icon_power_button_tb.png")
	local nowPlayingButton        = _loadImageTile(imgpath .. "Icons/icon_nplay_button_tb.png")
	local playlistButton          = _loadImageTile(imgpath .. "Icons/icon_nplay_list_tb.png")
	local moreButton              = _loadImageTile(imgpath .. "Icons/icon_more_tb.png")
	local touchToolbarBackground  = _loadTile(self.tiles, {imgpath .. "Touch_Toolbar/toolbar_tch_bkgrd.png"})
	local sliderBackground        = _loadImageTile(imgpath .. "Touch_Toolbar/toolbar_lrg.png")
	local touchToolbarKeyDivider  = _loadImageTile(imgpath .. "Touch_Toolbar/toolbar_divider.png")
	local deleteKeyBackground     = _loadImageTile(imgpath .. "Buttons/button_delete_text_entry.png")
	local deleteKeyPressedBackground = _loadImageTile(imgpath .. "Buttons/button_delete_text_entry_press.png")
    local helpTextBackground  = _loadImageTile(imgpath .. "Titlebar/tbar_dropdwn_bkrgd.png")


	local blackBackground   = Tile:fillColor(0x000000ff)

	--FIXME, _r asset here doesn't work...it's supposed to have a fadeout effect and it doesn't appear on screen
	local fiveItemBox             = _loadHTile(self.hTiles, {
		imgpath .. "5_line_lists/tch_5line_divider_l.png",
		imgpath .. "5_line_lists/tch_5line_divider.png",
		imgpath .. "5_line_lists/tch_5line_divider_r.png",
	})
	local fiveItemSelectionBox    = _loadHTile(self.hTiles, {
		imgpath .. "5_line_lists/menu_sel_box_5line_l.png",
		imgpath .. "5_line_lists/menu_sel_box_5line.png",
		imgpath .. "5_line_lists/menu_sel_box_5line_r.png",
	})
	local fiveItemPressedBox      = _loadHTile(self.hTiles, {
		imgpath .. "5_line_lists/menu_sel_box_5line_press_l.png",
		imgpath .. "5_line_lists/menu_sel_box_5line_press.png",
		imgpath .. "5_line_lists/menu_sel_box_5line_press_r.png",
	})

	local threeItemSelectionBox            = _loadHTile(self.hTiles, {
		imgpath .. "3_line_lists/menu_sel_box_3line_l.png",
		imgpath .. "3_line_lists/menu_sel_box_3line.png",
		imgpath .. "3_line_lists/menu_sel_box_3line_r.png",
	})
	local threeItemPressedBox = _loadImageTile(imgpath .. "3_line_lists/menu_sel_box_3item_press.png")

	local contextMenuPressedBox    = _loadTile(self.tiles, {
		imgpath .. "Popup_Menu/button_cm_press.png",
		imgpath .. "Popup_Menu/button_cm_tl_press.png",
		imgpath .. "Popup_Menu/button_cm_t_press.png",
		imgpath .. "Popup_Menu/button_cm_tr_press.png",
		imgpath .. "Popup_Menu/button_cm_r_press.png",
		imgpath .. "Popup_Menu/button_cm_br_press.png",
		imgpath .. "Popup_Menu/button_cm_b_press.png",
		imgpath .. "Popup_Menu/button_cm_bl_press.png",
		imgpath .. "Popup_Menu/button_cm_l_press.png",
	})

	local keyTopLeft = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_tl.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_t.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_l.png",
	})

	local keyTopLeftPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_n_button_press.png",
		imgpath .. "Buttons/keybrd_nw_button_press_tl.png",
		imgpath .. "Buttons/keybrd_n_button_press_t.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Buttons/keybrd_nw_button_press_l.png",
	})

	local keyTop = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_t_wvert.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyTopPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_n_button_press.png",
		nil,
		imgpath .. "Buttons/keybrd_n_button_press_t.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyTopRight = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_t_wvert.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_tr.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_r.png",
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyTopRightPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_n_button_press.png",
		nil,
		imgpath .. "Buttons/keybrd_n_button_press_t.png",
		imgpath .. "Buttons/keybrd_ne_button_press_tr.png",
		imgpath .. "Buttons/keybrd_ne_button_press_r.png",
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyLeft = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardLeftEdge.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_l.png",
	})

	local keyLeftPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keyboard_button_press.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Buttons/keyboard_button_press.png",
	})

	local keyMiddle = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyMiddlePressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keyboard_button_press.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local sliderButtonPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keyboard_button_press.png",
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyRight = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardRightEdge.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_r.png",
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyRightPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keyboard_button_press.png",
		nil,
		nil,
		nil,
		imgpath .. "Buttons/keyboard_button_press.png",
		nil,
		nil,
		nil,
		nil,
	})

	local keyBottomLeft = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardLeftEdge.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_b.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_bl.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_l.png",
	})

	local keyBottomLeftPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_s_button_press.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardLeftEdge.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		imgpath .. "Buttons/keybrd_s_button_press_b.png",
		imgpath .. "Buttons/keybrd_sw_button_press_bl.png",
		imgpath .. "Buttons/keybrd_sw_button_press_l.png",
	})

	local keyBottom = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_b_wvert.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyBottomPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_s_button_press.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		nil,
		nil,
		nil,
		imgpath .. "Buttons/keybrd_s_button_press_b.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyBottomRight = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardRightEdge.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_r.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_br.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_bkgrd_b_wvert.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local keyBottomRightPressed = _loadTile(self.tiles, {
		imgpath .. "Buttons/keybrd_s_button_press.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_hort.png",
		imgpath .. "Text_Entry/Keyboard_Touch/keyboardRightEdge.png",
		imgpath .. "Buttons/keybrd_se_button_press_r.png",
		imgpath .. "Buttons/keybrd_se_button_press_br.png",
		imgpath .. "Buttons/keybrd_s_button_press_b.png",
		nil,
		imgpath .. "Text_Entry/Keyboard_Touch/keyboard_divider_vert.png",
	})

	local titleBox = _loadTile(self.tiles, {
		imgpath .. "Titlebar/titlebar.png",
		nil,
		nil,
		nil,
		nil,
		nil,
		imgpath .. "Titlebar/titlebar_shadow.png",
		nil,
		nil,
	})

	local textinputBackground = _loadTile(self.tiles, {
		imgpath .. "Text_Entry/Keyboard_Touch/titlebar_box.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_tl.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_t.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_tr.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_r.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_br.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_b.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_bl.png",
		imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_l.png",
	})

	local pressedTitlebarButtonBox = _loadTile(self.tiles, {
		imgpath .. "Buttons/button_titlebar_press.png",
		imgpath .. "Buttons/button_titlebar_tl_press.png",
		imgpath .. "Buttons/button_titlebar_t_press.png",
		imgpath .. "Buttons/button_titlebar_tr_press.png",
		imgpath .. "Buttons/button_titlebar_r_press.png",
		imgpath .. "Buttons/button_titlebar_br_press.png",
		imgpath .. "Buttons/button_titlebar_b_press.png",
		imgpath .. "Buttons/button_titlebar_bl_press.png",
		imgpath .. "Buttons/button_titlebar_l_press.png",
	})

	local titlebarButtonBox = _loadTile(self.tiles, {
		imgpath .. "Buttons/button_titlebar.png",
		imgpath .. "Buttons/button_titlebar_tl.png",
		imgpath .. "Buttons/button_titlebar_t.png",
		imgpath .. "Buttons/button_titlebar_tr.png",
		imgpath .. "Buttons/button_titlebar_r.png",
		imgpath .. "Buttons/button_titlebar_br.png",
		imgpath .. "Buttons/button_titlebar_b.png",
		imgpath .. "Buttons/button_titlebar_bl.png",
		imgpath .. "Buttons/button_titlebar_l.png",
	})

	local popupBox = _loadTile(self.tiles, {
		imgpath .. "Popup_Menu/popup_box.png",
		imgpath .. "Popup_Menu/popup_box_tl.png",
		imgpath .. "Popup_Menu/popup_box_t.png",
		imgpath .. "Popup_Menu/popup_box_tr.png",
		imgpath .. "Popup_Menu/popup_box_r.png",
		imgpath .. "Popup_Menu/popup_box_br.png",
		imgpath .. "Popup_Menu/popup_box_b.png",
		imgpath .. "Popup_Menu/popup_box_bl.png",
		imgpath .. "Popup_Menu/popup_box_l.png",
	})

	local contextMenuBox = _loadTile(self.tiles, {
		imgpath .. "Popup_Menu/cm_popup_box.png",
		imgpath .. "Popup_Menu/cm_popup_box_tl.png",
		imgpath .. "Popup_Menu/cm_popup_box_t.png",
		imgpath .. "Popup_Menu/cm_popup_box_tr.png",
		imgpath .. "Popup_Menu/cm_popup_box_r.png",
		imgpath .. "Popup_Menu/cm_popup_box_br.png",
		imgpath .. "Popup_Menu/cm_popup_box_b.png",
		imgpath .. "Popup_Menu/cm_popup_box_bl.png",
		imgpath .. "Popup_Menu/cm_popup_box_l.png",
	})

	local scrollBackground = _loadVTile(self.vTiles, {
		imgpath .. "Scroll_Bar/scrollbar_bkgrd_t.png",
		imgpath .. "Scroll_Bar/scrollbar_bkgrd.png",
		imgpath .. "Scroll_Bar/scrollbar_bkgrd_b.png",
	})

	local scrollBar = _loadVTile(self.vTiles, {
		imgpath .. "Scroll_Bar/scrollbar_body_t.png",
		imgpath .. "Scroll_Bar/scrollbar_body.png",
		imgpath .. "Scroll_Bar/scrollbar_body_b.png",
	})

	local popupBackground = blackBackground

	local textinputCursor = _loadImageTile(imgpath .. "Text_Entry/Keyboard_Touch/tch_cursor.png")

	local THUMB_SIZE = self:param().THUMB_SIZE

	local TITLE_PADDING  = { 0, GAP_15, 0, GAP_15 }
	local CHECK_PADDING  = { GAP_2, 0, GAP_6, 0 }
	local CHECKBOX_RADIO_PADDING  = { GAP_2, 0, 0, 0 }

	local MENU_ITEM_ICON_PADDING = { 0, 0, GAP_8, 0 }
	local MENU_PLAYLISTITEM_TEXT_PADDING = { GAP_16, GAP_1, GAP_9, GAP_1 }

	local MENU_CURRENTALBUM_TEXT_PADDING = { GAP_6, GAP_20, 0, GAP_10 }
	local TEXTAREA_PADDING = { GAP_13, GAP_8, GAP_8, 0 }

	local TEXT_COLOR = { 0xE7, 0xE7, 0xE7 }
	local TEXT_COLOR_BLACK = { 0x00, 0x00, 0x00 }
	local TEXT_SH_COLOR = { 0x37, 0x37, 0x37 }
	local TEXT_COLOR_TEAL = { 0, 0xbe, 0xbe }

	local SELECT_COLOR = { 0xE7, 0xE7, 0xE7 }
	local SELECT_SH_COLOR = { }

	local TITLE_HEIGHT = _dp(65)
	local CM_MENU_HEIGHT = _dp(45)

	local ITEM_ICON_ALIGN   = 'center'
	local THREE_ITEM_HEIGHT = _dp(72)
	local FIVE_ITEM_HEIGHT = _dp(45)
	local TITLE_BUTTON_WIDTH = _dp(76)

	local smallSpinny = {
		img = _loadImage(imgpath .. "Alerts/wifi_connecting_sm.png"),
		frameRate = 8,
		frameWidth = 26, -- _dp(26) - can't use _dp here because it's a pixel size of the image
		padding = 0,
		h = WH_FILL,
	}
	local largeSpinny = {
		img = _loadImage(imgpath .. "Alerts/wifi_connecting.png"),
		position = LAYOUT_CENTER,
		w = WH_FILL,
		align = "center",
		frameRate = 8,
		frameWidth = 120, -- _dp(120) - can't use _dp here because it's a pixel size of the image
		padding = { 0, 0, 0, GAP_10 }
	}
	-- convenience method for removing a button from the window
	local noButton = {
		img = false,
		bgImg = false,
		w = 0
	}

	local playArrow = { 
		img = _loadImage(imgpath .. "Icons/selection_play_3line_on.png"),
	}
	local addArrow  = { 
		img = _loadImage(imgpath .. "Icons/selection_add_3line_on.png"),
	}
	local favItem  = { 
		img = _loadImage(imgpath .. "Icons/icon_toolbar_fav.png"),
	}


	---- REVIEWED BELOW THIS LINE ----

--------- CONSTANTS ---------

	local _progressBackground = _loadImageTile(imgpath .. "Alerts/alert_progress_bar_bkgrd.png")

	local _progressBar = _loadHTile(self.hTiles, {
		nil,
		imgpath .. "Alerts/alert_progress_bar_body.png",
	})

	local _songProgressBackground = _loadHTile(self.hTiles, {
		imgpath .. "Song_Progress_Bar/SP_Bar_Touch/tch_progressbar_bkgrd_l.png",
		imgpath .. "Song_Progress_Bar/SP_Bar_Touch/tch_progressbar_bkgrd.png",
		imgpath .. "Song_Progress_Bar/SP_Bar_Touch/tch_progressbar_bkgrd_r.png",
	})

	local _songProgressBar = _loadHTile(self.hTiles, {
		nil,
		nil,
		imgpath .. "Song_Progress_Bar/SP_Bar_Touch/tch_progressbar_slider.png"
	})

	local _songProgressBarDisabled = _loadHTile(self.hTiles, {
		nil,
		nil,
		imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progressbar_slider.png"
	})

	local _vizProgressBar = _loadHTile(self.hTiles, {
		imgpath .. "UNOFFICIAL/viz_progress_fill_l.png",
		imgpath .. "UNOFFICIAL/viz_progress_fill.png",
		imgpath .. "UNOFFICIAL/viz_progress_fill_r.png",
	})
	local _vizProgressBarPill = _loadImageTile(imgpath .. "UNOFFICIAL/viz_progress_slider.png")

	local _volumeSliderBackground = _loadHTile(self.hTiles, {
		imgpath .. "Touch_Toolbar/tch_volumebar_bkgrd_l.png",
		imgpath .. "Touch_Toolbar/tch_volumebar_bkgrd.png",
		imgpath .. "Touch_Toolbar/tch_volumebar_bkgrd_r.png",
	})

	local _volumeSliderBar = _loadHTile(self.hTiles, {
		imgpath .. "UNOFFICIAL/tch_volumebar_fill_l.png",
		imgpath .. "UNOFFICIAL/tch_volumebar_fill.png",
		imgpath .. "UNOFFICIAL/tch_volumebar_fill_r.png",
	})

	local _volumeSliderPill = _loadImageTile(imgpath .. "Touch_Toolbar/tch_volume_slider.png")

	local _popupSliderBar = _loadHTile(self.hTiles, {
		imgpath .. "Touch_Toolbar/tch_volumebar_fill_l.png",
		imgpath .. "Touch_Toolbar/tch_volumebar_fill.png",
		imgpath .. "Touch_Toolbar/tch_volumebar_fill_r.png",
	})

--------- DEFAULT WIDGET STYLES ---------
	--
	-- These are the default styles for the widgets 

	s.window = {
		w = w,
		h = h,
	}

	-- window with absolute positioning
	s.absolute = _uses(s.window, {
		layout = Window.noLayout,
	})

	s.popup = _uses(s.window, {
		border = { 0, 0, 0, 0 },
		bgImg = popupBackground,
	})

	s.title = {
		h = TITLE_HEIGHT,
		border = 0,
		position = LAYOUT_NORTH,
		bgImg = titleBox,
		padding = { 0, GAP_5, 0, GAP_5 },
		order = { "lbutton", "text", "rbutton" },
		lbutton = {
			border = { GAP_8, 0, GAP_8, 0 },
			h = WH_FILL,
		},
		rbutton = {
			border = { GAP_8, 0, GAP_8, 0 },
			h = WH_FILL,
		},
		text = {
			w = WH_FILL,
			padding = TITLE_PADDING,
			align = "center",
			font = _boldfont(FONT_SIZE_S),
			fg = TEXT_COLOR,
		}
	}

	s.title.textButton = _uses(s.title.text, {
		bgImg = titlebarButtonBox,
		padding = { GAP_4, GAP_15, GAP_4, GAP_15 },
	})

	s.title.pressed = {
		textButton = _uses(s.title.textButton, {
			bgImg = pressedTitlebarButtonBox,
		}),
	}

	s.text_block_black = {
		bgImg = blackBackground,
		position = LAYOUT_NORTH,
		h = _dp(300),
		order = { 'text' },
		text = {
			w = WH_FILL,
			h = _dp(300),
			padding = { GAP_10, GAP_160, GAP_10, 0 },
			align = "center",
			font = _font(FONT_SIZE_XXL),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
	}

	s.menu = {
		position = LAYOUT_CENTER,
		padding = { 0, 0, 0, 0 },
		itemHeight = FIVE_ITEM_HEIGHT,
		fg = {0xbb, 0xbb, 0xbb },
		font = _boldfont(FONT_SIZE_XXL),
	}

	s.menu_hidden = _uses(s.menu, {
		hidden = 1,
	})

	s.item = {
		h = FIVE_ITEM_HEIGHT,
		order = { "icon", "text", "arrow" },
		padding = { GAP_12, 0, GAP_8, 0 },
		text = {
			padding = { 0, 0, GAP_2, 0 },
			align = "left",
			w = WH_FILL,
			h = WH_FILL,
			font = _boldfont(FONT_SIZE_S),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
		icon = {
			padding = MENU_ITEM_ICON_PADDING,
			align = 'center',
		},
		arrow = {
			align = ITEM_ICON_ALIGN,
			img = _loadImage(imgpath .. "Icons/selection_right_5line.png"),
			padding = { 0, 0, 0, 0 },
		},
		bgImg = fiveItemBox,
	}

	s.item_play = _uses(s.item, { 
		arrow = { img = false },
	})
	s.item_add = _uses(s.item, { 
		arrow = addArrow 
	})

	-- Checkbox
	s.checkbox = {
		align = 'center',
		padding = CHECKBOX_RADIO_PADDING,
		h = WH_FILL,
		img_on = _loadImage(imgpath .. "Icons/checkbox_on.png"),
		img_off = _loadImage(imgpath .. "Icons/checkbox_off.png"),
	}

	-- Radio button
	s.radio = {
		align = 'center',
		padding = CHECKBOX_RADIO_PADDING,
		h = WH_FILL,
		img_on = _loadImage(imgpath .. "Icons/radiobutton_on.png"),
		img_off = _loadImage(imgpath .. "Icons/radiobutton_off.png"),
	}
	s.item_choice = _uses(s.item, {
		order  = { 'icon', 'text', 'check' },
		choice = {
			h = WH_FILL,
			padding = CHECKBOX_RADIO_PADDING,
			align = 'right',
			font = _boldfont(FONT_SIZE_S),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
	})
	s.item_checked = _uses(s.item, {
		order = { "icon", "text", "check", "arrow" },
		check = {
			align = ITEM_ICON_ALIGN,
			padding = CHECK_PADDING,
			img = _loadImage(imgpath .. "Icons/icon_check_5line.png")
		}
	})

	s.item_info = _uses(s.item, {
		order = { 'text' },
		padding = { GAP_12, 0, 0, 0 },
		text = {
			align = "top-left",
			w = WH_FILL,
			h = WH_FILL,
			padding = { 0, GAP_6, 0, GAP_6 },
			font = _font(FONT_SIZE_XXS),
			line = {
				{
					font = _font(FONT_SIZE_XXS),
					height = _dp(14),
				},
				{
					font = _boldfont(FONT_SIZE_XS),
					height = _dp(18),
				},
			},
		},
	})

	s.item_no_arrow = _uses(s.item, {
		order = { 'icon', 'text' },
	})
	s.item_checked_no_arrow = _uses(s.item, {
		order = { 'icon', 'text', 'check' },
	})

	s.selected = {
		item = _uses(s.item, {
			bgImg = fiveItemSelectionBox,
		}),
		item_play = _uses(s.item_play, {
			bgImg = fiveItemSelectionBox,
		}),
		item_add = _uses(s.item_add, {
			bgImg = fiveItemSelectionBox,
		}),
		item_checked = _uses(s.item_checked, {
			bgImg = fiveItemSelectionBox,
		}),
		item_no_arrow = _uses(s.item_no_arrow, {
			bgImg = fiveItemSelectionBox,
		}),
		item_checked_no_arrow = _uses(s.item_checked_no_arrow, {
			bgImg = fiveItemSelectionBox,
		}),
		item_choice = _uses(s.item_choice, {
			bgImg = fiveItemSelectionBox,
		}),
	}

	s.pressed = {
		item = _uses(s.item, {
			bgImg = fiveItemPressedBox,
		}),
		item_checked = _uses(s.item_checked, {
			bgImg = fiveItemPressedBox,
		}),
		item_play = _uses(s.item_play, {
			bgImg = fiveItemPressedBox,
		}),
		item_add = _uses(s.item_add, {
			bgImg = fiveItemPressedBox,
		}),
		item_no_arrow = _uses(s.item_no_arrow, {
			bgImg = fiveItemPressedBox,
		}),
		item_checked_no_arrow = _uses(s.item_checked_no_arrow, {
			bgImg = fiveItemPressedBox,
		}),
		item_choice = _uses(s.item_choice, {
			bgImg = fiveItemPressedBox,
		}),
		item_info = _uses(s.item_info, {
			bgImg = fiveItemPressedBox,
		}),
	}

	s.locked = {
		item = _uses(s.pressed.item, {
			arrow = smallSpinny
		}),
		item_checked = _uses(s.pressed.item_checked, {
			arrow = smallSpinny
		}),
		item_play = _uses(s.pressed.item_play, {
			arrow = smallSpinny
		}),
		item_add = _uses(s.pressed.item_add, {
			arrow = smallSpinny
		}),
		item_no_arrow = _uses(s.item_no_arrow, {
			arrow = smallSpinny
		}),
		item_checked_no_arrow = _uses(s.item_checked_no_arrow, {
			arrow = smallSpinny
		}),
		item_info         = _uses(s.item_info, {
			arrow = smallSpinny,
		}),
	}

	s.item_blank = {
		padding = {  },
		text = {},
		bgImg = helpTextBackground,
	}

	s.pressed.item_blank = _uses(s.item_blank)
	s.selected.item_blank = _uses(s.item_blank)

	s.help_text = {
		w = w - _dp(30),
		padding = { GAP_12, GAP_8, GAP_12, 0 },
		border = 0,
		font = _font(FONT_SIZE_XS),
		lineHeight = _dp(23),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "top-left",
	}

	s.scrollbar = {
		w = _dp(46),
		border = 0,
		padding = { 0, 0, 0, 0 },
		horizontal = 0,
		bgImg = scrollBackground,
		img = scrollBar,
		layer = LAYER_CONTENT_ON_STAGE,
	}

	s.text = {
		w = w,
		h = WH_FILL,
		padding = TEXTAREA_PADDING,
		font = _boldfont(FONT_SIZE_XS),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "left",
	}

	s.multiline_text = {
		w = WH_FILL,
		padding = { GAP_10, 0, GAP_2, GAP_10 },
		font = _font(FONT_SIZE_XS),
		height = _dp(21),
		fg = { 0xe6, 0xe6, 0xe6 },
		sh = { },
		align = "left",
	}
	s.multiline_popup_text = _uses(s.multiline_text, {
		padding = { GAP_14, GAP_18, GAP_14, GAP_18 },
		border = { 0, 0, GAP_10, 0 },
	})

	s.slider = {
		border = GAP_10,
		position = LAYOUT_SOUTH,
		horizontal = 1,
		bgImg = _progressBackground,
		img = _progressBar,
	}

	s.slider_group = {
		w = WH_FILL,
		border = { 0, GAP_5, 0, GAP_10 },
		order = { "min", "slider", "max" },
	}


--------- SPECIAL WIDGETS ---------


	-- text input
	s.textinput = {
		h = _dp(72),
		padding = { GAP_24, 0, GAP_24, 0 },
		font = _boldfont(FONT_SIZE_XL),
		cursorFont = _boldfont(FONT_SIZE_XL),
		wheelFont = _boldfont(FONT_SIZE_XL),
		charHeight = FONT_SIZE_XL,
		fg = TEXT_COLOR_BLACK,
		charOffsetY = _dp(32),
		wh = { 0x55, 0x55, 0x55 },
		cursorImg = textinputCursor,
	}

	-- keyboard
	s.keyboard = {
		w = WH_FILL,
		h = WH_FILL,
		border = { GAP_8, GAP_6, GAP_8, 0 },
		padding = { GAP_2, 0, GAP_2, 0 },
	}

	s.keyboard_textinput = {
		bgImg = textinputBackground,
		w = WH_FILL,
		order = { "textinput", "backspace" },
		border = 0,
		textinput = {
			padding = { GAP_16, 0, 0, GAP_4 },
		},
	}

	s.keyboard.key = {
		font = _boldfont(FONT_SIZE_L),
		fg = { 0xDC, 0xDC, 0xDC },
		align = 'center',
		bgImg = keyMiddle,
	}

	s.keyboard.key_topLeft     = _uses(s.keyboard.key, { bgImg = keyTopLeft })
	s.keyboard.key_top         = _uses(s.keyboard.key, { bgImg = keyTop })
	s.keyboard.key_topRight    = _uses(s.keyboard.key, { bgImg = keyTopRight })
	s.keyboard.key_left        = _uses(s.keyboard.key, { bgImg = keyLeft })
	s.keyboard.key_middle      = _uses(s.keyboard.key, { bgImg = keyMiddle })
	s.keyboard.key_right       = _uses(s.keyboard.key, { bgImg = keyRight })
	s.keyboard.key_bottomLeft  = _uses(s.keyboard.key, { bgImg = keyBottomLeft })
	s.keyboard.key_bottom      = _uses(s.keyboard.key, { bgImg = keyBottom })
	s.keyboard.key_bottomRight = _uses(s.keyboard.key, { bgImg = keyBottomRight })

	-- styles for keys that use smaller font 
	s.keyboard.key_bottom_small      = _uses(s.keyboard.key_bottom, { font = _boldfont(FONT_SIZE_M) } )
	s.keyboard.key_bottomRight_small = _uses(s.keyboard.key_bottomRight, {
		font = _boldfont(FONT_SIZE_M),
		fg = { 0xe7, 0xe7, 0xe7 },
	} )
	s.keyboard.key_bottomLeft_small  = _uses(s.keyboard.key_bottomLeft, { font = _boldfont(FONT_SIZE_M) } )
	s.keyboard.key_left_small        = _uses(s.keyboard.key_left, { font = _boldfont(FONT_SIZE_M) } )


	s.keyboard.spacer_topLeft     = _uses(s.keyboard.key_topLeft)
	s.keyboard.spacer_top         = _uses(s.keyboard.key_top)
	s.keyboard.spacer_topRight    = _uses(s.keyboard.key_topRight)
	s.keyboard.spacer_left        = _uses(s.keyboard.key_left)
	s.keyboard.spacer_middle      = _uses(s.keyboard.key_middle)
	s.keyboard.spacer_right       = _uses(s.keyboard.key_right)
	s.keyboard.spacer_bottomLeft  = _uses(s.keyboard.key_bottomLeft)
	s.keyboard.spacer_bottom      = _uses(s.keyboard.key_bottom)
	s.keyboard.spacer_bottomRight = _uses(s.keyboard.key_bottomRight)

	s.keyboard.shiftOff = _uses(s.keyboard.key_left, {
		img = _loadImage(imgpath .. "Icons/icon_shift_off.png"),
		padding = { GAP_1, 0, 0, 0 },
	})
	s.keyboard.shiftOn = _uses(s.keyboard.key_left, {
		img = _loadImage(imgpath .. "Icons/icon_shift_on.png"),
		padding = { GAP_1, 0, 0, 0 },
	})

	s.keyboard.arrow_left_middle = _uses(s.keyboard.key_middle, {
		img = _loadImage(imgpath .. "Icons/icon_arrow_left.png")
	})
	s.keyboard.arrow_right_right = _uses(s.keyboard.key_right, {
		img = _loadImage(imgpath .. "Icons/icon_arrow_right.png")
	})
	s.keyboard.arrow_left_bottom = _uses(s.keyboard.key_bottom, {
		img = _loadImage(imgpath .. "Icons/icon_arrow_left.png")
	})
	s.keyboard.arrow_right_bottom = _uses(s.keyboard.key_bottom, {
		img = _loadImage(imgpath .. "Icons/icon_arrow_right.png")
	})


	s.keyboard.done = {
		text = _uses(s.keyboard.key_bottomRight_small, {
			text = self:string("ENTER_SMALL"),
			fg = { 0x00, 0xbe, 0xbe },
			sh = { },
			h = WH_FILL,
			padding = { 0, 0, 0, GAP_1 },
		}),
		icon = { hidden = 1 },
	}

	s.keyboard.doneDisabled =  _uses(s.keyboard.done, {
		text = {
			fg = { 0x66, 0x66, 0x66 },
		}
	})

	s.keyboard.doneSpinny =  {
		icon = _uses(s.keyboard.key_bottomRight, {
			bgImg = keyBottomRight,
			hidden = 0,
			img = _loadImage(imgpath .. "Alerts/wifi_connecting_sm.png"),
			frameRate = 8,
			frameWidth = _dp(26),
			w = WH_FILL, 
			h = WH_FILL,
			align = 'center',
		}),
		text = { hidden = 1, w = 0 },
	}


	s.keyboard.space = _uses(s.keyboard.key_bottom_small, {
		bgImg = keyBottom,
		text = self:string("SPACEBAR_SMALL"),
	})

	s.keyboard.pressed = {
		shiftOff = _uses(s.keyboard.shiftOff, {
			bgImg = keyLeftPressed
		}),
		shiftOn = _uses(s.keyboard.shiftOn, {
			bgImg = keyLeftPressed
		}),
		done = _uses(s.keyboard.done, {
			bgImg = keyBottomRightPressed,
		}),
		doneDisabled = _uses(s.keyboard.doneDisabled, {
			-- disabled, not set
		}),
		doneSpinny = _uses(s.keyboard.doneSpinny, {
			-- disabled, not set
		}),
		space = _uses(s.keyboard.space, {
			bgImg = keyBottomPressed
		}),
		arrow_right_bottom = _uses(s.keyboard.arrow_right_bottom, {
			bgImg = keyBottomPressed
		}),
		arrow_right_right = _uses(s.keyboard.arrow_right_right, {
			bgImg = keyRightPressed
		}),
		arrow_left_bottom = _uses(s.keyboard.arrow_left_bottom, {
			bgImg = keyBottomPressed
		}),
		arrow_left_middle = _uses(s.keyboard.arrow_left_middle, {
			bgImg = keyMiddlePressed
		}),
		key = _uses(s.keyboard.key, {
			bgImg = keyMiddlePressed
		}),
		key_topLeft     = _uses(s.keyboard.key_topLeft, {
			bgImg = keyTopLeftPressed
		}),
		key_top         = _uses(s.keyboard.key_top, {
			bgImg = keyTopPressed
		}),
		key_topRight    = _uses(s.keyboard.key_topRight, {
			bgImg = keyTopRightPressed
		}),
		key_left        = _uses(s.keyboard.key_left, {
			bgImg = keyLeftPressed
		}),
		key_middle      = _uses(s.keyboard.key_middle, {
			bgImg = keyMiddlePressed
		}),
		key_right       = _uses(s.keyboard.key_right, {
			bgImg = keyRightPressed
		}),
		key_bottomLeft  = _uses(s.keyboard.key_bottomLeft, {
			bgImg = keyBottomLeftPressed
		}),
		key_bottom      = _uses(s.keyboard.key_bottom, {
			bgImg = keyBottomPressed
		}),
		key_bottomRight = _uses(s.keyboard.key_bottomRight, {
			bgImg = keyBottomRightPressed
		}),
		key_left_small  = _uses(s.keyboard.key_left_small, {
			bgImg = keyLeftPressed
		}),
		key_bottomLeft_small  = _uses(s.keyboard.key_bottomLeft_small, {
			bgImg = keyBottomLeftPressed
		}),
		key_bottom_small      = _uses(s.keyboard.key_bottom_small, {
			bgImg = keyBottomPressed
		}),
		key_bottomRight_small = _uses(s.keyboard.key_bottomRight_small, {
			bgImg = keyBottomRightPressed
		}),

		spacer_topLeft     = _uses(s.keyboard.spacer_topLeft),
		spacer_top         = _uses(s.keyboard.spacer_top),
		spacer_topRight    = _uses(s.keyboard.spacer_topRight),
		spacer_left        = _uses(s.keyboard.spacer_left),
		spacer_middle      = _uses(s.keyboard.spacer_middle),
		spacer_right       = _uses(s.keyboard.spacer_right),
		spacer_bottomLeft  = _uses(s.keyboard.spacer_bottomLeft),
		spacer_bottom      = _uses(s.keyboard.spacer_bottom),
		spacer_bottomRight = _uses(s.keyboard.spacer_bottomRight),
	}

	local _timeFirstColumnX12h = _dp(218)
	local _timeFirstColumnX24h = _dp(280)

	s.time_input_background_12h = {
		w = WH_FILL,
		h = h - TITLE_HEIGHT,
		position = LAYOUT_NONE,
		img = _loadImage(imgpath .. "Multi_Character_Entry/tch_multi_char_bkgrd_3c.png"),
		x = 0,
		y = TITLE_HEIGHT,
	}

	s.time_input_background_24h = {
		w = WH_FILL,
		h = h - TITLE_HEIGHT,
		position = LAYOUT_NONE,
		img = _loadImage(imgpath .. "Multi_Character_Entry/tch_multi_char_bkgrd_2c.png"),
		x = 0,
		y = TITLE_HEIGHT,
	}

	s.time_input_menu_box_12h = {
		position = LAYOUT_NONE,
		img = _loadImage(imgpath .. "Multi_Character_Entry/menu_box_fixed.png"),
		w = _dp(370),
		h = _dp(80),
		x = _dp(216),
		y = _dp(228),
	}
	s.time_input_menu_box_24h = _uses(s.time_input_menu_box_12h, {
		-- img = _loadImage(imgpath .. self, "UNOFFICIAL/menu_box_fixed_2c.png"),
		w = _dp(242),
		x = _dp(278),
	})

	-- time input window
	s.input_time_12h = _uses(s.window)
	s.input_time_12h.hour = _uses(s.menu, {
		w = _dp(100),
		h = h,
		itemHeight = _dp(80),
		position = LAYOUT_WEST,
		padding = 0,
		border = { _timeFirstColumnX12h, TITLE_HEIGHT, 0, 0 },
		item = {
			bgImg = false,
			order = { 'text' },
			text = {
				align = 'right',
				font = _boldfont(FONT_SIZE_L),
				padding = { GAP_2, GAP_4, GAP_8, 0 },
				fg = { 0xb3, 0xb3, 0xb3 },
				sh = { },
			},
		},
		selected = {
			item = {
				order = { 'text' },
				bgImg = false,
				text = {
					font = _boldfont(FONT_SIZE_L),
					fg = { 0xe6, 0xe6, 0xe6 },
					sh = { },
					align = 'right',
					padding = { GAP_2, GAP_4, GAP_8, 0 },
				},
			},
		},
		pressed = {
			item = {
				order = { 'text' },
				bgImg = false,
				text = {
					font = _boldfont(FONT_SIZE_L),
					fg = { 0xe6, 0xe6, 0xe6 },
					sh = { },
					align = 'right',
					padding = { GAP_2, GAP_4, GAP_8, 0 },
				},
			},
		},
	})
	s.input_time_12h.minute = _uses(s.input_time_12h.hour, {
		border = { _timeFirstColumnX12h + _dp(125), TITLE_HEIGHT, 0, 0 },
	})
	s.input_time_12h.ampm = _uses(s.input_time_12h.hour, {
		border = { _timeFirstColumnX12h + _dp(125) + _dp(120), TITLE_HEIGHT, 0, 0 },
		item = {
			text = {
				padding = { 0, GAP_2, GAP_8, 0 },
				font = _boldfont(FONT_SIZE_S),
			},
		},
		selected = {
			item = {
				text = {
					padding = { 0, GAP_4, GAP_8, 0 },
					font = _boldfont(FONT_SIZE_S),
				},
			},
		},
		pressed = {
			item = {
				text = {
					padding = { 0, GAP_4, GAP_8, 0 },
					font = _boldfont(FONT_SIZE_S),
				},
			},
		},
	})
	s.input_time_12h.hourUnselected   = s.input_time_12h.hour
	s.input_time_12h.minuteUnselected = s.input_time_12h.minute
	s.input_time_12h.ampmUnselected   = s.input_time_12h.ampm

	s.input_time_24h = _uses(s.input_time_12h, {
		hour = {
			border = { _timeFirstColumnX24h, TITLE_HEIGHT, 0, 0 },
		},
		minute = {
			border = { _timeFirstColumnX24h + _dp(124), TITLE_HEIGHT, 0, 0 },
		},
		hourUnselected = {
			border = { _timeFirstColumnX24h, TITLE_HEIGHT, 0, 0 },
		},
		minuteUnselected = {
			border = { _timeFirstColumnX24h + _dp(124), TITLE_HEIGHT, 0, 0 },
		},
	})

	-- one set for buttons, one for spacers

--------- WINDOW STYLES ---------
	--
	-- These styles override the default styles for a specific window

	-- typical text list window
	s.text_list = _uses(s.window)

	-- text_only removes icons
	s.text_only = _uses(s.text_list, {
		menu = {
			item = {
				order = { 'text', 'arrow', },
			},
			selected = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
			pressed = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
			locked = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
		},
	})

	s.text_list.title = _uses(s.title, {
		text = {
			line = {
				{
					font = _boldfont(FONT_SIZE_S),
					height = _dp(32),
				},
				{
					font = _font(FONT_SIZE_XXS),
					fg   = { 0xB3, 0xB3, 0xB3 },
				},
			},
		},
	})

	s.text_list.title.textButton = _uses(s.text_list.title.text, {
		bgImg = titlebarButtonBox,
		padding = { GAP_4, GAP_15, GAP_4, GAP_15 },
	})
	s.text_list.title.pressed = {}
	s.text_list.title.pressed.textButton = _uses(s.text_list.title.text, {
		bgImg = pressedTitlebarButtonBox,
		padding = { GAP_4, GAP_15, GAP_4, GAP_15 },
	})

	-- choose player window is exactly the same as text_list on all windows except WQVGAlarge
	s.choose_player = s.text_list

	s.multiline_text_list = _uses(s.text_list)

	s.multiline_text_list.menu = _uses(s.menu, {
		itemHeight = THREE_ITEM_HEIGHT,
		item = {
			h = THREE_ITEM_HEIGHT,
			padding = { GAP_10, GAP_8, 0, GAP_8 },
			bgImg = false,
			icon = {
				align = 'top',
			},
		},
	})

	s.multiline_text_list.menu.item_no_arrow = _uses(s.multiline_text_list.menu.item)

	s.multiline_text_list.menu.selected = {}
	s.multiline_text_list.menu.selected.item = _uses(s.multiline_text_list.menu.item, {
		bgImg = threeItemSelectionBox,
		h = THREE_ITEM_HEIGHT,
	})
	s.multiline_text_list.menu.selected.item_no_arrow = _uses(s.multiline_text_list.menu.selected.item)

	s.multiline_text_list.menu.pressed = {}
	s.multiline_text_list.menu.pressed.item = _uses(s.multiline_text_list.menu.item, {
		bgImg = threeItemPressedBox,
		h = THREE_ITEM_HEIGHT,
	})
	s.multiline_text_list.menu.pressed.item_no_arrow = _uses(s.multiline_text_list.menu.pressed.item)

	-- popup "spinny" window
	s.waiting_popup = _uses(s.popup, {
		text = {
			w = WH_FILL,
			h = FONT_SIZE_S + _dp(8),
			position = LAYOUT_NORTH,
			border = { 0, GAP_50, 0, 0 },
			padding = { GAP_15, 0, GAP_15, 0 },
			align = "center",
			font = _font(FONT_SIZE_S),
			lineHeight = FONT_SIZE_S + _dp(8),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
		subtext = {
			w = WH_FILL,
			h = _dp(47),
			position = LAYOUT_SOUTH,
			border = { 0, 0, 0, GAP_20 },
			padding = { GAP_15, 0, GAP_15, 0 },
			align = "top",
			font = _boldfont(FONT_SIZE_S),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
	})

	s.waiting_popup.subtext_connected = _uses(s.waiting_popup.subtext, {
		fg = TEXT_COLOR_TEAL,
	})

	s.black_popup = _uses(s.waiting_popup)
	s.black_popup.title = _uses(s.title, {
		bgImg = false,
		order = { },
	})

	-- input window (including keyboard)
	s.input = _uses(s.window)
	s.input.title = _uses(s.title, {
		bgImg = inputTitleBox,
	})

	local clearMask = Tile:fillColor(0x00000000)

	s.power_on_window =  _uses(s.window)
	s.power_on_window.maskImg = clearMask
	s.power_on_window.title = _uses(s.title, {
		bgImg = false,
	})

	-- update window
	s.update_popup = _uses(s.popup, {
		text = {
			w = WH_FILL,
			h = FONT_SIZE_S + _dp(8),
			position = LAYOUT_NORTH,
			border = { 0, GAP_34, 0, GAP_2 },
			padding = { GAP_10, 0, GAP_10, 0 },
			align = "center",
			font = _font(FONT_SIZE_S),
			lineHeight = FONT_SIZE_S + _dp(8),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
		subtext = {
			w = WH_FILL,
			h = _dp(30),
			padding = { 0, 0, 0, GAP_28 },
			font = _boldfont(FONT_SIZE_XS),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
			align = "bottom",
			position = LAYOUT_SOUTH,
		},

		progress = {
			border = { GAP_15, GAP_7, GAP_15, GAP_17 },
			position = LAYOUT_SOUTH,
			horizontal = 1,
			bgImg = _progressBackground,
			img = _progressBar,
		},
	})

	s.home_menu = _uses(s.text_list, {
		menu = {
			item = _uses(s.item, {
				icon = {
					img = _loadImage(imgpath .. "IconsResized/icon_loading" .. skinSuffix)
				},
			}),
			selected = {
				item = _uses(s.selected.item, {
					icon = {
						img = _loadImage(imgpath .. "IconsResized/icon_loading" .. skinSuffix),
					},
				}),
			},
			locked = {
				item = _uses(s.locked.item, {
					icon = {
						img = _loadImage(imgpath .. "IconsResized/icon_loading" .. skinSuffix),
					},
				}),
			},
		},
	})

	s.home_menu.menu.item.icon_no_artwork = {
		img = _loadImage(imgpath .. "IconsResized/icon_loading" .. skinSuffix ),
		h   = THUMB_SIZE,
		padding = MENU_ITEM_ICON_PADDING,
		align = 'center',
	}
	s.home_menu.menu.selected.item.icon_no_artwork = _uses(s.home_menu.menu.item.icon_no_artwork)
	s.home_menu.menu.locked.item.icon_no_artwork = _uses(s.home_menu.menu.item.icon_no_artwork)

	-- icon_list window
	s.icon_list = _uses(s.window, {
		menu = {
			item = {
				h = FIVE_ITEM_HEIGHT,
				order = { "icon", "text", "arrow" },
				padding = { GAP_12, 0, 0, 0 },
				text = {
					w = WH_FILL,
					h = WH_FILL,
					align = 'left',
					font = _font(FONT_SIZE_XS),
					line = {
						{
							font = _boldfont(FONT_SIZE_XS),
							height = _dp(22),
						},
						{
							font = _font(FONT_SIZE_XS),
						},
					},
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
				},
				icon = {
					h = THUMB_SIZE,
					padding = MENU_ITEM_ICON_PADDING,
					align = 'center',
				},
				arrow = _uses(s.item.arrow),
			},
		},
	})

	s.icon_list.menu.item_checked = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text', 'check', 'arrow' },
		check = {
			align = ITEM_ICON_ALIGN,
			padding = CHECK_PADDING,
			img = _loadImage(imgpath .. "Icons/icon_check_5line.png")
		},
	})
	s.icon_list.menu.item_play = _uses(s.icon_list.menu.item, { 
		arrow = { img = false },
	})
	s.icon_list.menu.albumcurrent = _uses(s.icon_list.menu.item_play, {
		arrow = { 
			img = _loadImage(imgpath .. "Icons/icon_nplay_3line_off.png"),
		},
		text = { padding = 0, },
		-- Bug 11482c#13, don't know why the bgImg has to be redefined again, but this fixes the issue
		bgImg = fiveItemBox,
	})
	s.icon_list.menu.item_add  = _uses(s.icon_list.menu.item, { 
		arrow = addArrow,
	})
	s.icon_list.menu.item_no_arrow = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text' },
	})
	s.icon_list.menu.item_checked_no_arrow = _uses(s.icon_list.menu.item_checked, {
		order = { 'icon', 'text', 'check' },
	})

	s.icon_list.menu.selected = {
		item = _uses(s.icon_list.menu.item, {
			bgImg = fiveItemSelectionBox
		}),
		albumcurrent = _uses(s.icon_list.menu.albumcurrent, {
			arrow = {
				img = _loadImage(imgpath .. "Icons/icon_nplay_3line_sel.png"),
			},
			bgImg = fiveItemSelectionBox,
		}),
		item_checked = _uses(s.icon_list.menu.item_checked, {
			bgImg = fiveItemSelectionBox
		}),
		item_play = _uses(s.icon_list.menu.item_play, {
			bgImg = fiveItemSelectionBox
		}),
		item_add = _uses(s.icon_list.menu.item_add, {
			bgImg = fiveItemSelectionBox
		}),
		item_no_arrow = _uses(s.icon_list.menu.item_no_arrow, {
			bgImg = fiveItemSelectionBox
		}),
		item_checked_no_arrow = _uses(s.icon_list.menu.item_checked_no_arrow, {
			bgImg = fiveItemSelectionBox
		}),
	}

	s.icon_list.menu.pressed = {
		item = _uses(s.icon_list.menu.item, {
			bgImg = fiveItemPressedBox
		}),
		albumcurrent = _uses(s.icon_list.menu.albumcurrent, {
			bgImg = fiveItemSelectionBox
		}),
		item_checked = _uses(s.icon_list.menu.item_checked, {
			bgImg = fiveItemPressedBox
		}),
		item_play = _uses(s.icon_list.menu.item_play, {
			bgImg = fiveItemPressedBox
		}),
		item_add = _uses(s.icon_list.menu.item_add, {
			bgImg = fiveItemPressedBox
		}),
		item_no_arrow = _uses(s.icon_list.menu.item_no_arrow, {
			bgImg = fiveItemPressedBox
		}),
		item_checked_no_arrow = _uses(s.icon_list.menu.item_checked_no_arrow, {
			bgImg = fiveItemPressedBox
		}),
	}

	s.icon_list.menu.locked = {
		item = _uses(s.icon_list.menu.pressed.item, {
			arrow = smallSpinny
		}),
		item_checked = _uses(s.icon_list.menu.pressed.item_checked, {
			arrow = smallSpinny
		}),
		item_play = _uses(s.icon_list.menu.pressed.item_play, {
			arrow = smallSpinny
		}),
		item_add = _uses(s.icon_list.menu.pressed.item_add, {
			arrow = smallSpinny
		}),
		albumcurrent = _uses(s.icon_list.menu.pressed.albumcurrent, {
			arrow = smallSpinny
		}),
	}

	-- list window with help text
	s.help_list = _uses(s.text_list)

--[[
	-- BUG 11662, help_list used to have the top textarea fill the available space. That's been removed, but leaving this code in for now as an example of how to do that
	s.help_list = _uses(s.window)

	s.help_list.menu = _uses(s.menu, {
		position = LAYOUT_SOUTH,
		maxHeight = FIVE_ITEM_HEIGHT * 3,
		itemHeight = FIVE_ITEM_HEIGHT,
	})

	s.help_list.help_text = _uses(s.help_text, {
		h = WH_FILL,
		align = "left"
	})
--]]

	-- error window
	-- XXX: needs layout
	s.error = _uses(s.help_list)


	-- information window
	s.information = _uses(s.window)

	s.information.text = {
		font = _font(FONT_SIZE_XS),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		padding = { GAP_18, GAP_18, GAP_10, 0},
		lineHeight = _dp(23),
	}

	-- help window (likely the same as information)
	s.help_info = _uses(s.information)


	--track_list window
	-- XXXX todo
	-- identical to text_list but has icon in upper left of titlebar
	s.track_list = _uses(s.text_list)

	s.track_list.title = _uses(s.title, {
		order = { 'lbutton', 'icon', 'text', 'rbutton' },
		icon  = {
			w = THUMB_SIZE,
			h = WH_FILL,
			padding = { GAP_10, GAP_1, GAP_8, GAP_1 },
		},
	})

	-- playlist same as icon list
	s.play_list = _uses(s.icon_list)

	-- toast_popup popup (is now text only)
	s.toast_popup_textarea = {
		padding = { GAP_20, GAP_20, GAP_20, GAP_20 } ,
		align = 'left',
		w = WH_FILL,
		h = WH_FILL,
		font = _font(FONT_SIZE_S),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
	}

	-- toast_popup popup with art and text
	s.toast_popup = {
		x = _dp(100),
		y = h/2/2,
		w = w - _dp(200),
		h = h/2,
		bgImg = popupBox,
		group = {
			padding = GAP_10,
			order = { 'icon', 'text' },
			text = { 
				padding = { GAP_10, GAP_12, GAP_12, GAP_12 } ,
				align = 'top-left',
				w = WH_FILL,
				h = WH_FILL,
				font = _font(FONT_SIZE_XS),
				lineHeight = FONT_SIZE_XS + _dp(5),
			},
			icon = { 
				align = 'top-left', 
				border = { GAP_12, GAP_12, 0, 0 },
				img = _loadImage(imgpath .. "UNOFFICIAL/menu_album_noartwork_64.png"),
				h = WH_FILL,
				w = _dp(64),
			}
		}
	}
	-- toast popup with textarea
	s.toast_popup_text = _uses(s.toast_popup, {
		group = {
			order = { 'text' },
			text = {
				w = WH_FILL,
				h = WH_FILL,
				align = 'top-left',
				padding = { GAP_10, GAP_12, GAP_12, GAP_12 },
				fg = TEXT_COLOR,
				sh = TEXT_SH_COLOR,
			},
		}
	})

	-- toast popup with icon only
	s.toast_popup_icon = _uses(s.toast_popup, {
		w = _dp(190),
		h = _dp(178),
		x = (w - _dp(190)) / 2,
		y = (h - _dp(170)) / 2,
		position = LAYOUT_NONE,
		group = {
			order = { 'icon' },
			border = { GAP_22, GAP_22, 0, 0 },
			padding = 0,
			icon = {
				w = WH_FILL,
				h = WH_FILL,
				align = 'center',
			},
		}
	})

	-- new style that incorporates text, icon, more text, and maybe a badge
	s.toast_popup_mixed = {
		x = _dp(100),
		y = (h - _dp(250)) / 2,
		position = LAYOUT_NONE,
		w = w - _dp(200),
		h = _dp(250),
		bgImg = popupBox,
		text = {
			position = LAYOUT_NORTH,
			padding = { GAP_8, GAP_24, GAP_8, 0 },
			align = 'top',
			w = WH_FILL,
			h = WH_FILL,
			font = _font(FONT_SIZE_S),
			lineHeight = FONT_SIZE_S + _dp(5),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
		subtext = {
			position = LAYOUT_NORTH,
			padding = { GAP_8, GAP_200, GAP_8, 0 },
			align = 'top',
			w = WH_FILL,
			h = WH_FILL,
			font = _font(FONT_SIZE_S),
			lineHeight = FONT_SIZE_S + _dp(5),
				fg = TEXT_COLOR,
				sh = TEXT_SH_COLOR,
		},
	}

	s._badge = {
		position = LAYOUT_NONE,
		zOrder = 99,
		-- middle of the screen plus half of the icon width minus half of the badge width. gotta love LAYOUT_NONE
		x = (w - _dp(200))/2 + self:param().POPUP_THUMB_SIZE/2 - _dp(17),
		w = _dp(34),
		y = _dp(48),
	}
	s.badge_none = _uses(s._badge, {
		img = false,
	})
	s.badge_favorite = _uses(s._badge, {
		img = _loadImage(imgpath .. "Icons/icon_badge_fav.png")
	})
	s.badge_add = _uses(s._badge, {
		img = _loadImage(imgpath .. "Icons/icon_badge_add.png")
	})

	local CM_MENU_ITEM_COUNT = math.floor(((h - _dp(32) - _dp(52) - _dp(20)) / CM_MENU_HEIGHT))

	s.context_menu = {
		x = _dp(8),
		y = _dp(16),
		w = w - _dp(16),
		h = h - _dp(32),
		bgImg = contextMenuBox,
		layer = LAYER_TITLE,

		multiline_text = {
            w = WH_FILL,
            h = _dp(172),
            padding = { GAP_18, GAP_2, GAP_14, GAP_18 },
            border = { 0, 0, GAP_6, GAP_15 },
            lineHeight = _dp(22),
            font = _font(FONT_SIZE_XS),
            fg = { 0xe6, 0xe6, 0xe6 },
            sh = { },
            align = "top-left",
            scrollbar = {
                h = _dp(164),
                border = {0, GAP_2, GAP_2, GAP_10 },
            },
        },

		title = {
			layer = LAYER_TITLE,
			h = _dp(52),
			padding = {GAP_10, GAP_10, GAP_10, GAP_5 },
			bgImg = false,
			button_cancel  = {
				layer = LAYER_TITLE,
				w       = _dp(43),
				align = 'right',
			},
			pressed = {
					button_cancel  = {
					bgImg = pressedTitlebarButtonBox,
					layer = LAYER_TITLE,
					w       = _dp(43),
				},
			},
			text = {
				layer = LAYER_TITLE,
				w = WH_FILL,
				padding = {0,0,GAP_20,0},
				align = "center",
				font = _boldfont(FONT_SIZE_XS),
				fg = TEXT_COLOR,
			},
		},

		menu = {
			h = CM_MENU_HEIGHT * CM_MENU_ITEM_COUNT,
			border = { GAP_7, 0, GAP_7, 0 },
			padding = { 0, 0, 0, GAP_100 },
			scrollbar = { 
				h = CM_MENU_HEIGHT * CM_MENU_ITEM_COUNT,
			},
			item = {
				h = CM_MENU_HEIGHT,
				order = { "text", "arrow" },
				padding = { GAP_12, 0, GAP_12, 0 },
				text = {
					padding = { 0, GAP_4, 0, 0 },
					w = WH_FILL,
					h = WH_FILL,
					align = 'left',
					font = _font(FONT_SIZE_XS),
					line = {
						{
							font = _boldfont(FONT_SIZE_XS),
							height = _dp(22),
						},
						{
							font = _font(FONT_SIZE_XS),
						},
					},
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
				},
				arrow = _uses(s.item.arrow),
			},
			selected = {
				item = {
					h = CM_MENU_HEIGHT,
					order = { "text", "arrow" },
					bgImg = fiveItemSelectionBox,
					padding = { GAP_12, 0, GAP_12, 0 },
					text = {
						padding = { 0, GAP_4, 0, 0 },
						w = WH_FILL,
						h = WH_FILL,
						align = 'left',
						font = _font(FONT_SIZE_XS),
						line = {
							{
								font = _boldfont(FONT_SIZE_XS),
								height = _dp(22),
							},
							{
								font = _font(FONT_SIZE_XS),
							},
						},
						fg = TEXT_COLOR,
						sh = TEXT_SH_COLOR,
					},
					arrow = _uses(s.item.arrow),
				},
			},
			
		},
	}
	
	s.context_menu.menu.item_play = _uses(s.context_menu.menu.item, {
		arrow = {img = playArrow.img},
	})
	s.context_menu.menu.selected.item_play = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = playArrow.img},
	})

	s.context_menu.menu.item_insert = _uses(s.context_menu.menu.item, {
		arrow = {img = addArrow.img},
	})
	s.context_menu.menu.selected.item_insert = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = addArrow.img},
	})

	s.context_menu.menu.item_add = _uses(s.context_menu.menu.item, {
		arrow = {img = addArrow.img},
	})
	s.context_menu.menu.selected.item_add = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = addArrow.img},
	})

	s.context_menu.menu.item_playall = _uses(s.context_menu.menu.item, {
		arrow = {img = playArrow.img},
	})
	s.context_menu.menu.selected.item_playall = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = playArrow.img},
	})

	s.context_menu.menu.item_fav = _uses(s.context_menu.menu.item, {
		arrow = {img = favItem.img},
	})
	s.context_menu.menu.selected.item_fav = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = favItem.img},
	})

	s.context_menu.menu.item_no_arrow = _uses(s.context_menu.menu.item, {
		order = { 'text' },
	})
	s.context_menu.menu.selected.item_no_arrow = _uses(s.context_menu.menu.selected.item, {
		order = { 'text' },
	})

	s.context_menu.menu.pressed = _uses(s.context_menu.menu.selected, {
		item = {
			bgImg = contextMenuPressedBox,
		},
	})

	s.context_menu.menu.locked = _uses(s.context_menu.menu.pressed, {
		item = {
			arrow = smallSpinny,
		},
	})

	-- alarm popup
	s.alarm_header = {
			w = w,
			--padding = { 50, 0, 50, 0 },
			--order = { 'icon', 'time' },
			order = { 'time' },
	}

	s.alarm_time = {
		w = w - _dp(20),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "center",
		font = _boldfont(FONT_SIZE_L),
	}

	s.preview_text = _uses(s.alarm_time, {
		font = _boldfont(FONT_SIZE_XS),
	})
	
	-- alarm menu window
	s.alarm_popup = {
		x = _dp(10),
		y = _dp(10),
		w = w - _dp(20),
		h = h - _dp(17),
		border = 0,
		padding = 0,
		bgImg = contextMenuBox,
		layer = LAYER_TITLE,

		title = {
			hidden = 1,
		},

		menu = {
			h = CM_MENU_HEIGHT * 5,
			w = w - _dp(34),
			x = _dp(7),
			y = _dp(65),
			border = 0,
			itemHeight = CM_MENU_HEIGHT,
			position = LAYOUT_NORTH,
			scrollbar = { 
				h = CM_MENU_HEIGHT * 5 - _dp(8),
				border = {0,GAP_4,0,0},
			},
			item = {
				h = CM_MENU_HEIGHT,
				order = { "text", "arrow" },
				text = {
					w = WH_FILL,
					h = WH_FILL,
					align = 'left',
					font = _boldfont(FONT_SIZE_S),
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
				},
				arrow = _uses(s.item.arrow),
			},
			selected = {
				item = {
					h = CM_MENU_HEIGHT,
					bgImg = fiveItemSelectionBox,
					order = { "text", "arrow" },
					text = {
						w = WH_FILL,
						h = WH_FILL,
						align = 'left',
						font = _boldfont(FONT_SIZE_S),
						fg = TEXT_COLOR,
						sh = TEXT_SH_COLOR,
					},
					arrow = _uses(s.item.arrow),
				},
			},

		},
	}
	-- slider popup (volume)
	s.slider_popup = {
		x = _dp(50),
		y = h/2 - _dp(100),
		w = w - _dp(100),
		h = _dp(200),
		bgImg = popupBox,
		heading = {
			w = WH_FILL,
			border = GAP_10,
			fg = TEXT_COLOR,
			font = _boldfont(FONT_SIZE_M),
			padding = { GAP_4, GAP_16, GAP_4, 0 },
			align = "center",
			bgImg = false,
		},
		slider_group = {
			w = WH_FILL,
			align = 'center',
			padding = { GAP_10, 0, GAP_10, 0 },
			order = { 'slider' },
		},
	}


       -- scanner popup
	s.scanner_popup = _uses(s.slider_popup, {
		h = _dp(110),
		y = h/2 - _dp(55),
	})

	s.image_popup = _uses(s.popup, {
		image = {
			w = w,
			position = LAYOUT_CENTER,
			align = "center",
			h = h,
			border = 0,
		},
	})


--------- SLIDERS ---------


	s.volume_slider = {
		w = WH_FILL,
		border = { 0, 0, 0, 0 },
		bgImg = _volumeSliderBackground,
		img = _popupSliderBar,
	}

	s.scanner_slider = _uses(s.volume_slider, {
		img = _volumeSliderBar,
	})
	
--------- BUTTONS ---------

	-- base button
	local _button = {
		bgImg = titlebarButtonBox,
		w = TITLE_BUTTON_WIDTH,
		h = WH_FILL,
		border = { GAP_8, 0, GAP_8, 0 },
		icon = {
			w = WH_FILL,
			h = WH_FILL,
			hidden = 1,
			align = 'center',
			img = false,
		},
		text = {
			w = WH_FILL,
			h = WH_FILL,
			hidden = 1,
			border = 0,
			padding = 0,
			align = 'center',
			font = _font(FONT_SIZE_XS),
			fg = { 0xdc,0xdc, 0xdc },
			sh = TEXT_SH_COLOR,
		},
	}
	local _pressed_button = _uses(_button, {
		bgImg = pressedTitlebarButtonBox,
	})


	-- icon button factory
	local _titleButtonIcon = function(s, name, icon)
		s[name] = _uses(_button)
		s[name].layer = LAYER_TITLE

		s.pressed[name] = _uses(_pressed_button)

		attr = {
			hidden = 0,
			img = icon,
			layer = LAYER_TITLE,
		}

		s[name].icon = _uses(_button.icon, attr)
		s[name].w = _dp(65)
		s.pressed[name].icon = _uses(_pressed_button.icon, attr)
		s.pressed[name].w = _dp(65)
	end

	-- text button factory
	local _titleButtonText = function(s, name, string)
		s[name] = _uses(_button)
		s.pressed[name] = _uses(_pressed_button)

		attr = {
			hidden = 0,
			text = string,
		}

		s[name].text = _uses(_button.text, attr)
		s[name].w = _dp(65)
		s.pressed[name].text = _uses(_pressed_button.text, attr)
		s.pressed[name].w = _dp(65)
	end

	-- text button factory
	local _titleButtonTextIcon = function(s, name, string)
		s[name] = _uses(_button)
		s.pressed[name] = _uses(_pressed_button)

		attr = {
			hidden = 0,
			text = string,
			font = _iconFont(FONT_SIZE_S),
		}

		s[name].text = _uses(_button.text, attr)
		s[name].w = _dp(65)
		s.pressed[name].text = _uses(_pressed_button.text, attr)
		s.pressed[name].w = _dp(65)
	end

	-- invisible button
	s.button_none = _uses(_button, {
		bgImg    = false,
		w = TITLE_BUTTON_WIDTH  - _dp(12),
	})

	_titleButtonTextIcon(s, "button_back", _icons.arrow_back)
	_titleButtonTextIcon(s, "button_cancel", _icons.close)
	_titleButtonTextIcon(s, "button_go_home", _icons.home)
	_titleButtonTextIcon(s, "button_playlist", _icons.queue_music)
	_titleButtonTextIcon(s, "button_more", _icons.more_vert)
	_titleButtonTextIcon(s, "button_go_playlist", _icons.queue_music)
	_titleButtonTextIcon(s, "button_go_now_playing", _icons.audiotrack)
	_titleButtonTextIcon(s, "button_power", _icons.power_settings_new)
	_titleButtonTextIcon(s, "button_nothing", nil)
	_titleButtonTextIcon(s, "button_help", _icons.help)
	_titleButtonText(s, "button_more_help", self:string("MORE_HELP"))
	_titleButtonTextIcon(s, "button_finish_operation", _icons.done)

	s.button_back.padding     = { GAP_2, 0, 0, GAP_2 }
	s.button_playlist.padding = { GAP_2, 0, 0, GAP_2 }

	s.button_volume_min = {
		img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_down.png"),
		border = { GAP_5, 0, GAP_5, 0 },
	}

	s.button_volume_max = {
		img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_up.png"),
		border = { GAP_5, 0, GAP_5, 0 },
	}

	s.button_keyboard_back = {
		align = 'left',
		w = _dp(96),
		h = _dp(66),
		padding = { GAP_14, 0, 0, 0 },
		border = { 0, GAP_2, GAP_9, GAP_5 }, 
		img = _loadImage(imgpath .. "Icons/icon_delete_tch_text_entry.png"),
		bgImg = deleteKeyBackground,
	}
	s.pressed.button_keyboard_back = _uses(s.button_keyboard_back, {
		bgImg = deleteKeyPressedBackground,
	})


	local _buttonicon = {
		h   = THUMB_SIZE,
		padding = MENU_ITEM_ICON_PADDING,
		align = 'center',
		img = false,
	}

	s.region_US = _uses(_buttonicon, { 
		img = _loadImage(imgpath .. "IconsResized/icon_region_americas" .. skinSuffix),
	})
	s.region_XX = _uses(_buttonicon, { 
		img = _loadImage(imgpath .. "IconsResized/icon_region_other" .. skinSuffix),
	})
	s.icon_help = _uses(_buttonicon, { 
		img = _loadImage(imgpath .. "IconsResized/icon_help" .. skinSuffix),
	})
	s.wlan = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_wireless" .. skinSuffix),
	})
	s.wired = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ethernet" .. skinSuffix),
	})


--------- ICONS --------

	-- icons used for 'waiting' and 'update' windows
	local _icon = {
		w = WH_FILL,
		align = "center",
		position = LAYOUT_CENTER,
		padding = { 0, 0, 0, GAP_10 }
	}

	local _popupicon = {
		padding = 0,
		border = { GAP_22, GAP_18, 0, 0 },
		h = WH_FILL,
		w = _dp(166),
	}

	-- icon for albums with no artwork
	s.icon_no_artwork = {
		img = _loadImage(imgpath .. "IconsResized/icon_album_noart" .. skinSuffix ),
		h   = THUMB_SIZE,
		padding = MENU_ITEM_ICON_PADDING,
		align = 'center',
	}

	s.icon_no_artwork_playlist = _uses(s.icon_no_artwork)

	s.icon_connecting = _uses(_icon, {
		img = _loadImage(imgpath .. "Alerts/wifi_connecting.png"),
		frameRate = 8,
		frameWidth = _dp(120),
		padding = { 0, GAP_90, 0, GAP_10 },
	})

	s.icon_connected = _uses(_icon, {
		img = _loadImage(imgpath .. "Alerts/connecting_success_icon.png"),
		padding = { 0, GAP_2, 0, GAP_10 },
	})

	s.icon_photo_loading = _uses(_icon, {
		img = _loadImage(imgpath .. "Icons/image_viewer_loading.png"),
	})

	s.icon_software_update = _uses(_icon, {
		img = _loadImage(imgpath .. "IconsResized/icon_firmware_update" .. skinSuffix),
	})

	s.icon_restart = _uses(_icon, {
		img = _loadImage(imgpath .. "IconsResized/icon_restart" .. skinSuffix),
	})

	s.icon_popup_pause = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_pause.png"),
	})

	s.icon_popup_play = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_play.png"),
	})

	s.icon_popup_fwd = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_fwd.png"),
	})
	s.icon_popup_rew = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_rew.png"),
	})

	s.icon_popup_stop = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_stop.png"),
	})
	s.icon_popup_lineIn = _uses(_popupicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_linein_134.png"),
	})

	s.icon_popup_volume = {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_volume_bar.png"),
		w = WH_FILL,
		h = _dp(90),
		align = 'center',
		padding = { 0, GAP_5, 0, GAP_5 },
	}

	s.icon_popup_mute = _uses(s.icon_popup_volume, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_volume_mute.png"),
	})

	s.icon_popup_shuffle0 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_shuffle_off.png"),
	})

	s.icon_popup_shuffle1 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_shuffle.png"),
	})

	s.icon_popup_shuffle2 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_shuffle_album.png"),
	})

	s.icon_popup_repeat0 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_repeat_off.png"),
	})

	s.icon_popup_repeat1 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_repeat_song.png"),
	})

	s.icon_popup_repeat2 = _uses(_popupicon, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_repeat.png"),
	})

	s.icon_popup_sleep_15 = {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_15.png"),
		h = WH_FILL,
		w = WH_FILL,
		padding = { GAP_24, GAP_24, 0, 0 },
	}
	s.icon_popup_sleep_30 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_30.png"),
	})
	s.icon_popup_sleep_45 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_45.png"),
	})
	s.icon_popup_sleep_60 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_60.png"),
	})
	s.icon_popup_sleep_90 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_90.png"),
	})
	s.icon_popup_sleep_cancel = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(imgpath .. "Icons/icon_popup_box_sleep_off.png"),
		padding = { GAP_24, GAP_34, 0, 0 },
	})

	s.icon_power = _uses(_icon, {
		img = _loadImage(imgpath .. "IconsResized/icon_restart" .. skinSuffix),
	})

	s.icon_locked = _uses(_icon, {
-- FIXME no asset for this (needed?)
--		img = _loadImage(imgpath .. self, "Alerts/popup_locked_icon.png"),
	})

	s.icon_alarm = {
		img = _loadImage(imgpath .. "Icons/icon_alarm.png"),
	}

	s.icon_art = _uses(_icon, {
		padding = 0,
		img = false,
	})

	s.player_transporter = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_transporter" .. skinSuffix),
	})
	s.player_squeezebox = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_SB1n2" .. skinSuffix),
	})
	s.player_squeezebox2 = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_SB1n2" .. skinSuffix),
	})
	s.player_squeezebox3 = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_SB3" .. skinSuffix),
	})
	s.player_boom = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_boom" .. skinSuffix),
	})
	s.player_slimp3 = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_slimp3" .. skinSuffix),
	})
	s.player_softsqueeze = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_softsqueeze" .. skinSuffix),
	})
	s.player_controller = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_controller" .. skinSuffix),
	})
	s.player_receiver = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_receiver" .. skinSuffix),
	})
	s.player_squeezeplay = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_squeezeplay" .. skinSuffix),
	})
	s.player_http = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_tunein_url" .. skinSuffix),
	})
	s.player_baby = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_baby" .. skinSuffix),
	})
	s.player_fab4 = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_fab4" .. skinSuffix),
	})

	-- misc home menu icons
	s.hm_appletImageViewer = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_image_viewer" .. skinSuffix),
	})
	s.hm_eject = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_eject" .. skinSuffix),
	})
	s.hm_sdcard = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_device_SDcard" .. skinSuffix),
	})
	s.hm_usbdrive = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_device_USB" .. skinSuffix),
	})
	s.hm_appletNowPlaying = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_nowplaying" .. skinSuffix),
	})
	s.hm_settings = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings" .. skinSuffix),
	})
	s.hm_advancedSettings = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_adv" .. skinSuffix),
	})
	s.hm_settings_pcp = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_pcp" .. skinSuffix),
	})
	s.hm_radio = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_tunein" .. skinSuffix),
	})
	s.hm_radios = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_tunein" .. skinSuffix),
	})
	s.hm_myApps = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_my_apps" .. skinSuffix),
	})
	s.hm_myMusic = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_mymusic" .. skinSuffix),
	})
	s.hm__myMusic = _uses(s.hm_myMusic)
	s.hm_otherLibrary = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_other_library" .. skinSuffix),
	})
	s.hm_myMusicSelector = _uses(s.hm_myMusic)

	s.hm_favorites = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_favorites" .. skinSuffix),
	})
	s.hm_settingsAlarm = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_alarm" .. skinSuffix),
	})
	s.hm_settingsPlayerNameChange = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_name" .. skinSuffix),
	})
	s.hm_settingsBrightness = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_brightness" .. skinSuffix),
	})
	s.hm_settingsSync = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_sync" .. skinSuffix),
	})
	s.hm_selectPlayer = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_choose_player" .. skinSuffix),
	})
	s.hm_quit = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_power_off" .. skinSuffix),
	})
	s.hm_playerpower = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_power_off" .. skinSuffix),
	})
	s.hm_myMusicArtists = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_artist" .. skinSuffix),
	})
	s.hm_myMusicAlbums = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_albums" .. skinSuffix),
	})
	s.hm_myMusicGenres = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_genres" .. skinSuffix),
	})
	s.hm_myMusicYears = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_years" .. skinSuffix),
	})

	s.hm_myMusicNewMusic = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_new_music" .. skinSuffix),
	})
	s.hm_myMusicPlaylists = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_playlist" .. skinSuffix),
	})
	s.hm_myMusicSearch = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_search" .. skinSuffix),
	})
	s.hm_myMusicSearchArtists   = _uses(s.hm_myMusicSearch)
	s.hm_myMusicSearchAlbums    = _uses(s.hm_myMusicSearch)
	s.hm_myMusicSearchSongs     = _uses(s.hm_myMusicSearch)
	s.hm_myMusicSearchPlaylists = _uses(s.hm_myMusicSearch)
	s.hm_myMusicSearchRecent    = _uses(s.hm_myMusicSearch)
	s.hm_homeSearchRecent       = _uses(s.hm_myMusicSearch)
	s.hm_globalSearch           = _uses(s.hm_myMusicSearch)

	s.hm_myMusicMusicFolder = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_folder" .. skinSuffix),
	})
	s.hm_randomplay = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_ml_random" .. skinSuffix),
	})
	s.hm_skinTest = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_blank" .. skinSuffix),
	})

	s.hm_settingsRepeat = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_repeat" .. skinSuffix),
	})
	s.hm_settingsShuffle = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_shuffle" .. skinSuffix),
	})
	s.hm_settingsSleep = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_sleep" .. skinSuffix),
	})
	s.hm_settingsScreen = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_screen" .. skinSuffix),
	})
	s.hm_appletCustomizeHome = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_home" .. skinSuffix),
	})
	s.hm_settingsAudio = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_audio" .. skinSuffix),
	})
	s.hm_linein = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_linein" .. skinSuffix),
	})

	-- ??
	s.hm_loading = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_loading" .. skinSuffix),
	})
	-- ??
	s.hm_settingsPlugin = _uses(_buttonicon, {
		img = _loadImage(imgpath .. "IconsResized/icon_settings_plugin" .. skinSuffix),
	})

	-- indicator icons, on right of menus
	local _indicator = {
		align = "center",
	}

	s.wirelessLevel1 = _uses(_indicator, {
		img = _loadImage(imgpath .. "Icons/icon_wireless_1.png")
	})

	s.wirelessLevel2 = _uses(_indicator, {
		img = _loadImage(imgpath .. "Icons/icon_wireless_2.png")
	})

	s.wirelessLevel3 = _uses(_indicator, {
		img = _loadImage(imgpath .. "Icons/icon_wireless_3.png")
	})

	s.wirelessLevel4 = _uses(_indicator, {
		img = _loadImage(imgpath .. "Icons/icon_wireless_4.png")
	})


--------- ICONBAR ---------

	s.iconbar_group = {
		hidden = 1,
	}

	-- time (hidden off screen)
	s.button_time = {
		hidden = 1,
	}



	-- BEGIN NowPlaying skin code

	local controlHeight = _dp(72)
	local controlWidth = _dp(76)
	local volumeBarWidth = _dp(240) -- screenWidth - (transport controls + volume controls + dividers + border around volume bar)
	local buttonPadding = 0
	local iconsColor = { 0xdc,0xdc, 0xdc }
	local iconsColorActive = { 0x00,0xff,0xff }


	local _transportControlButton = {
		w = controlWidth,
		h = controlHeight,
		align = 'center',
		padding = buttonPadding,
		icon = {
			w = WH_FILL,
			h = WH_FILL,
			hidden = 1,
			align = 'center',
			img = false,
		},
		text = {
			w = WH_FILL,
			h = WH_FILL,
			hidden = 1,
			border = 0,
			padding = 0,
			align = 'center',
			font = _font(FONT_SIZE_XS),
			fg = iconsColor,
		},
	}

	local _transportControlBorder = _uses(_transportControlButton, {
		w = _dp(2),
		padding = 0,
		icon = {
			hidden = 0,
			img = touchToolbarKeyDivider,
		},
	})

	local _disabledColor = function(base)
		local scale = 0.6
		return {
			math.floor(base[1] * scale),
			math.floor(base[2] * scale),
			math.floor(base[3] * scale),
		}
	end

	local _pbButtonIcon = function(iconPath)
		local icon = _loadImage(imgpath .. iconPath)

		local o = _uses(_transportControlButton)

		o.icon = _uses(_transportControlButton.icon, {
			hidden = 0,
			img = icon,
			layer = LAYER_TITLE,
		})
		return o
	end

	-- text button factory
	local PB_BT_OFF = "off"
	local PB_BT_ON = "on"
	local PB_BT_DIS = "disabled"
	local colors = {
		off = iconsColor,
		on = iconsColorActive,
		disabled = _disabledColor(iconsColor),
	}
	local _pbButtonText = function(string, state)
		local state = state or PB_BT_OFF

		local o = _uses(_transportControlButton)

		o.text = _uses(_transportControlButton.text, {
			hidden = 0,
			text = string,
			font = _iconFont(FONT_SIZE_S),
			fg = colors[state],
		})
		return o
	end


	s.toolbar_spacer = _uses(_transportControlButton, {
		w = WH_FILL,
	})

	local _tracklayout = {
		border = { GAP_4, 0, GAP_4, 0 },
		position = LAYOUT_NONE,
		w = WH_FILL,
		align = "left",
		lineHeight = FONT_SIZE_M,
		fg = TEXT_COLOR,
		x = h - _dp(160) + _dp(5),
	}
	
	local maxArtwork = h - _dp(180)

	s.nowplaying = _uses(s.window, {
		--title bar
		title = _uses(s.title, {
			zOrder = 1,
			text = {
				font = _boldfont(FONT_SIZE_S),
				bgImg   = titlebarButtonBox,
			},
			rbutton  = {
				font    = _font(FONT_SIZE_XXS),
				fg      = TEXT_COLOR,
				bgImg   = titlebarButtonBox,
				w       = TITLE_BUTTON_WIDTH,
				padding = { GAP_8, 0, GAP_8, 0},
				align   = 'center',
			}
		}),
	
		-- Song metadata
		nptitle = {
			order = { 'nptrack' },
			position   = _tracklayout.position,
			border     = _tracklayout.border,
			x          = _tracklayout.x,
			y          = TITLE_HEIGHT + _dp(65),
			h          = FONT_SIZE_M,
			nptrack =  {
				w          = w - _tracklayout.x - _dp(10),
				h          = WH_FILL,
				align      = _tracklayout.align,
				lineHeight = _tracklayout.lineHeight,
				fg         = _tracklayout.fg,
				font       = _boldfont(FONT_SIZE_M), 
				sh = TEXT_SH_COLOR,
			},
		},
		npartistgroup = {
			order = { 'npartist' },
			position   = _tracklayout.position,
			border     = _tracklayout.border,
			x          = _tracklayout.x,
			y          = TITLE_HEIGHT + _dp(32) + _dp(32) + _dp(70),
			h          = _dp(32),
			npartist = {
				padding    = { 0, GAP_6, 0, 0 },
				w          = w - _tracklayout.x - _dp(10),
				align      = _tracklayout.align,
				lineHeight = _tracklayout.lineHeight,
				fg         = _tracklayout.fg,
				font       = _font(FONT_SIZE_S),
				sh = TEXT_SH_COLOR,
			},
		},
		npalbumgroup = {
			order = {'npalbum' },
			position   = _tracklayout.position,
			border     = _tracklayout.border,
			x          = _tracklayout.x,
			y          = TITLE_HEIGHT + _dp(32) + _dp(32) + _dp(32) + _dp(70) + _dp(10),
			h          = _dp(32),
			npalbum = {
				w          = w - _tracklayout.x - _dp(10),
				padding    = { 0, GAP_6, 0, 0 },
				align      = _tracklayout.align,
				lineHeight = _tracklayout.lineHeight,
				fg         = _tracklayout.fg,
				font       = _font(FONT_SIZE_S),
				sh = TEXT_SH_COLOR,
			},
		},
		npartistalbum = {
			hidden = 1,
		},
	
		-- cover art
		npartwork = {
			w = maxArtwork,
			position = LAYOUT_NONE,
			x = _dp(10),
			y = TITLE_HEIGHT + _dp(18),
			align = "center",
			h = maxArtwork,

			artwork = {
				w = maxArtwork,
				align = "center",
				padding = 0,
				img = false,
			},
		},

		npvisu = { hidden = 1 },
	
		--transport controls
		npcontrols = {
			order = { 'rew', 'div1', 'play', 'div2', 'fwd', 'div3', 'repeatMode', 'div4', 'shuffleMode', 
					'div5', 'volDown', 'div6', 'volSlider', 'div7', 'volUp' },
			position = LAYOUT_SOUTH,
			h = controlHeight,
			w = WH_FILL,
			bgImg = touchToolbarBackground,

			div1 = _uses(_transportControlBorder),
			div2 = _uses(_transportControlBorder),
			div3 = _uses(_transportControlBorder),
			div4 = _uses(_transportControlBorder),
			div5 = _uses(_transportControlBorder),
			div6 = _uses(_transportControlBorder),
			div7 = _uses(_transportControlBorder),

			-- Generic Buttons
			-- rew					= _pbButtonIcon("Icons/icon_toolbar_rew.png"),
			rew					= _pbButtonText(_icons.fast_rewind),
			-- rewDisabled			= _pbButtonIcon("Icons/icon_toolbar_rew_dis.png"),
			rewDisabled			= _pbButtonText(_icons.fast_rewind, PB_BT_DIS),
			-- play					= _pbButtonIcon("Icons/icon_toolbar_play.png"),
			play				= _pbButtonText(_icons.play_arrow),
			-- pause				= _pbButtonIcon("Icons/icon_toolbar_pause.png"),
			pause				= _pbButtonText(_icons.pause),
			-- fwd					= _pbButtonIcon("Icons/icon_toolbar_ffwd.png"),
			fwd					= _pbButtonText(_icons.fast_forward),
			-- fwdDisabled			= _pbButtonIcon("Icons/icon_toolbar_ffwd_dis.png"),
			fwdDisabled			= _pbButtonText(_icons.fast_forward, PB_BT_DIS),

			-- Shuffle Buttons
			-- shuffleMode 			= _pbButtonIcon("Icons/icon_toolbar_shuffle_off.png"),
			shuffleMode 		= _pbButtonText(_icons.shuffle),
			-- shuffleOff			= _pbButtonIcon("Icons/icon_toolbar_shuffle_off.png"),
			shuffleOff			= _pbButtonText(_icons.shuffle),
			-- shuffleSong			= _pbButtonIcon("Icons/icon_toolbar_shuffle_on.png"),
			shuffleSong			= _pbButtonText(_icons.shuffle, PB_BT_ON),
			-- shuffleAlbum			= _pbButtonIcon("Icons/icon_toolbar_shuffle_album_on.png"),
			shuffleAlbum		= _pbButtonText(_icons.shuffle_on, PB_BT_ON),
			-- shuffleDisabled		= _pbButtonIcon("Icons/icon_toolbar_shuffle_dis.png"),
			shuffleDisabled		= _pbButtonText(_icons.shuffle, PB_BT_DIS),

			-- Repeat Buttons
			-- repeatMode			= _pbButtonIcon("Icons/icon_toolbar_repeat_off.png"),
			repeatMode			= _pbButtonText(_icons.repeat_icon),
			-- repeatOff			= _pbButtonIcon("Icons/icon_toolbar_repeat_off.png"),
			repeatOff			= _pbButtonText(_icons.repeat_icon),
			-- repeatPlaylist		= _pbButtonIcon("Icons/icon_toolbar_repeat_on.png"),
			repeatPlaylist		= _pbButtonText(_icons.repeat_icon, PB_BT_ON),
			-- repeatSong			= _pbButtonIcon("Icons/icon_toolbar_repeat_song_on.png"),
			repeatSong			= _pbButtonText(_icons.repeat_one, PB_BT_ON),
			-- repeatDisabled		= _pbButtonIcon("Icons/icon_toolbar_repeat_dis.png"),
			repeatDisabled		= _pbButtonText(_icons.repeat_icon, PB_BT_DIS),

			-- Volume Buttons
			-- volDown				= _pbButtonIcon("Icons/icon_toolbar_vol_down.png"),
			volDown				= _pbButtonText(_icons.volume_down),
			-- volUp				= _pbButtonIcon("Icons/icon_toolbar_vol_up.png"),
			volUp				= _pbButtonText(_icons.volume_up),

			-- Social Buttons
			-- thumbsUp				= _pbButtonIcon("Icons/icon_toolbar_thumbup.png"),
			thumbsUp			= _pbButtonText(_icons.thumb_up),
			-- thumbsUpDisabled		= _pbButtonIcon("Icons/icon_toolbar_thumbup_dis.png"),
			thumbsUpDisabled	= _pbButtonText(_icons.thumbs_up, PB_BT_DIS),
			-- thumbsDown			= _pbButtonIcon("Icons/icon_toolbar_thumbdown.png"),
			thumbsDown			= _pbButtonText(_icons.thumb_down),
			-- thumbsDownDisabled	= _pbButtonIcon("Icons/icon_toolbar_thumbdown_dis.png"),
			thumbsDownDisabled	= _pbButtonText(_icons.thumbs_down, PB_BT_DIS),
			-- love					= _pbButtonIcon("Icons/icon_toolbar_love_on.png"),
			love				= _pbButtonText(_icons.heart),
			-- hate					= _pbButtonIcon("Icons/icon_toolbar_love_off.png"),
			hate				= _pbButtonText(_icons.heart_broken),
		},
	
		-- Progress bar
		npprogress = {
			position = LAYOUT_NONE,
			x = _tracklayout.x + 2,
			y = h - _dp(160),
			padding = { 0, GAP_11, 0, 0 },
			order = { "elapsed", "slider", "remain" },
			elapsed = {
				w = _dp(60),
				align = 'left',
				padding = { 0, 0, GAP_4, GAP_20 },
				font = _boldfont(FONT_SIZE_XS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			remain = {
				w = _dp(60),
				align = 'right',
				padding = { GAP_4, 0, 0, GAP_20 },
				font = _boldfont(FONT_SIZE_XS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			elapsedSmall = {
				w = _dp(60),
				align = 'left',
				padding = { 0, 0, GAP_4, GAP_20 },
				font = _boldfont(FONT_SIZE_XXS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			remainSmall = {
				w = _dp(60),
				align = 'right',
				padding = { GAP_4, 0, 0, GAP_20 },
				font = _boldfont(FONT_SIZE_XXS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			npprogressB = {
				w = w - _tracklayout.x - 2*_dp(80) - _dp(25),
				padding = { 0, 0, 0, 0 },
			    position = LAYOUT_CENTER,
				horizontal = 1,
				bgImg = _songProgressBackground,
				img = _songProgressBar,
			},
		},
	
		-- special style for when there shouldn't be a progress bar (e.g., internet radio streams)
		npprogressNB = {
			order = { "elapsed" },
			position = LAYOUT_NONE,
			x = _tracklayout.x + _dp(2),
			y = TITLE_HEIGHT + _dp(29) + _dp(26) + _dp(32) + _dp(32) + _dp(23) + _dp(84) + _dp(40),
			elapsed = {
				w = WH_FILL,
				align = "left",
				font = _boldfont(FONT_SIZE_XS),
				fg = { 0xe7, 0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
		},

	})
	s.nowplaying.npprogressNB.elapsedSmall = s.nowplaying.npprogressNB.elapsed

	-- sliders
	s.nowplaying.npprogress.npprogressB_disabled = _uses(s.nowplaying.npprogress.npprogressB, {
		img = _songProgressBarDisabled,
	})

	s.npvolumeB = {
		w = volumeBarWidth,
		border = { 0, GAP_20, 0, GAP_20 },
		padding = { 0, 0, 0, 0 },
		position = LAYOUT_CENTER,
		horizontal = 1,
		bgImg = _volumeSliderBackground,
		img = _volumeSliderBar,
		pillImg = _volumeSliderPill,
	}
	s.npvolumeB_disabled = _uses(s.npvolumeB, {
		pillImg = false,
	})

	-- pressed styles
	s.nowplaying.title.pressed = _uses(s.nowplaying.title, {
		text = {
			fg = { 0xB3, 0xB3, 0xB3 },
			sh = { },
			bgImg = pressedTitlebarButtonBox,
		},
		lbutton = {
			bgImg = pressedTitlebarButtonBox,
		},
		rbutton = {
			bgImg = pressedTitlebarButtonBox,
		},
	})

	s.nowplaying.pressed = _uses(s.nowplaying)
	s.nowplaying.nptitle.pressed = _uses(s.nowplaying.nptitle)
	s.nowplaying.npalbumgroup.pressed = _uses(s.nowplaying.npalbumgroup)
	s.nowplaying.npartistgroup.pressed = _uses(s.nowplaying.npartistgroup)
	s.nowplaying.npartwork.pressed = s.nowplaying.npartwork

	s.nowplaying.npcontrols.pressed = {
		rew     = _uses(s.nowplaying.npcontrols.rew, { bgImg = keyMiddlePressed }),
		play    = _uses(s.nowplaying.npcontrols.play, { bgImg = keyMiddlePressed }),
		pause   = _uses(s.nowplaying.npcontrols.pause, { bgImg = keyMiddlePressed }),
		fwd     = _uses(s.nowplaying.npcontrols.fwd, { bgImg = keyMiddlePressed }),
		repeatPlaylist  = _uses(s.nowplaying.npcontrols.repeatPlaylist, { bgImg = keyMiddlePressed }),
		repeatSong      = _uses(s.nowplaying.npcontrols.repeatSong, { bgImg = keyMiddlePressed }),
		repeatOff       = _uses(s.nowplaying.npcontrols.repeatOff, { bgImg = keyMiddlePressed }),
		repeatMode      = _uses(s.nowplaying.npcontrols.repeatMode, { bgImg = keyMiddlePressed }),
		shuffleAlbum    = _uses(s.nowplaying.npcontrols.shuffleAlbum, { bgImg = keyMiddlePressed }),
		shuffleSong     = _uses(s.nowplaying.npcontrols.shuffleSong, { bgImg = keyMiddlePressed }),
		shuffleMode      = _uses(s.nowplaying.npcontrols.shuffleMode, { bgImg = keyMiddlePressed }),
		shuffleOff      = _uses(s.nowplaying.npcontrols.shuffleOff, { bgImg = keyMiddlePressed }),
		volDown = _uses(s.nowplaying.npcontrols.volDown, { bgImg = keyMiddlePressed }),
		volUp   = _uses(s.nowplaying.npcontrols.volUp, { bgImg = keyMiddlePressed }),

		thumbsUp    = _uses(s.nowplaying.npcontrols.thumbsUp, { bgImg = keyMiddlePressed }),
		thumbsDown  = _uses(s.nowplaying.npcontrols.thumbsDown, { bgImg = keyMiddlePressed }),
		thumbsUpDisabled    = s.nowplaying.npcontrols.thumbsUpDisabled,
		thumbsDownDisabled  = s.nowplaying.npcontrols.thumbsDownDisabled,
		love        = _uses(s.nowplaying.npcontrols.love, { bgImg = keyMiddlePressed }),
		hate        = _uses(s.nowplaying.npcontrols.hate, { bgImg = keyMiddlePressed }),
		fwdDisabled = _uses(s.nowplaying.npcontrols.fwdDisabled),
		rewDisabled = _uses(s.nowplaying.npcontrols.rewDisabled),
		shuffleDisabled = _uses(s.nowplaying.npcontrols.shuffleDisabled),
		repeatDisabled = _uses(s.nowplaying.npcontrols.repeatDisabled),
	}


	local settings = appletManager:callService("getNowPlayingScreenButtons")
	local buttonOrder = {}
	local smallTbButtons

	local i = 1
	for k,v in ipairs(tbButtons) do
		if settings[v] then
			table.insert(buttonOrder, v)
			
			i = i + 1
			
			-- We can't comfortably accomodate more than five items
			if (w <= _dp(800) and i > 5) or (i > 2 and v == 'volSlider') then
				smallTbButtons = true
				if w <= _dp(800) then break end
			end
			
			table.insert(buttonOrder, 'div' .. tostring(i))
		end
	end
	
	local npX = h + _dp(15)

	s.nowplaying_large_art = _uses(s.nowplaying, {
		bgImg = blackBackground,
		title = {
			bgImg = false,
			text = {
				border = { h - _dp(72), 0, 0, 0 },
				padding = { GAP_10, GAP_12, GAP_10, GAP_15 },
				font = _boldfont(FONT_SIZE_S),
			},
			button_back = {
				bgImg = false
			}
		},
		nptitle = {
			x = npX,
			nptrack = {
				w = w - npX - _dp(10),
				font = _boldfont(FONT_SIZE_XS * 0.9), 
			},
		},
		npartistgroup = {
			x = npX,
			npartist = {
				font = _font(FONT_SIZE_XS * 0.9),
				w = w - npX - _dp(10),
			} 
		},
		npalbumgroup = {
			x = npX,
			npalbum = {
				font = _font(FONT_SIZE_XS * 0.9),
				w = w - npX - _dp(10),
			} 
		},
		npcontrols = {
			order = buttonOrder,
			x = h,
		},
		npprogress = {
			x = npX,
			elapsed = {
				w = _dp(60),
			},
			remain = {
				w = _dp(60),
			},
			npprogressB = {
				w = w - npX - 2*_dp(60) - _dp(15),
			},
		},
		npprogressNB = {
			x = npX,
		},
		npartwork = {
			w = h,
			x = 0,
			y = 0,
			align = "center",
			h = WH_FILL,
			artwork = {
				w = WH_FILL,
				h = WH_FILL,
				align = "left",
				padding = 0,
				img = false,
			},
		},

		npvisu = { hidden = 1 },
	})

	s.nowplaying_large_art.pressed = _uses(s.nowplaying_large_art)

	-- if we have more than four buttons, then make them smaller
	if (smallTbButtons) then
		local smallControlWidth = controlWidth - _dp(14)
		s.nowplaying_large_art.npcontrols.rew = _uses(s.nowplaying.npcontrols.rew, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.play = _uses(s.nowplaying.npcontrols.play, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.pause = _uses(s.nowplaying.npcontrols.pause, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.fwd = _uses(s.nowplaying.npcontrols.fwd, { w = smallControlWidth })
		
		s.nowplaying_large_art.npcontrols.repeatMode = _uses(s.nowplaying.npcontrols.repeatMode, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.repeatOff = _uses(s.nowplaying.npcontrols.repeatOff, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.repeatSong = _uses(s.nowplaying.npcontrols.repeatSong, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.repeatPlaylist = _uses(s.nowplaying.npcontrols.repeatPlaylist, { w = smallControlWidth })

		s.nowplaying_large_art.npcontrols.shuffleMode = _uses(s.nowplaying.npcontrols.shuffleMode, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.shuffleOff = _uses(s.nowplaying.npcontrols.shuffleOff, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.shuffleSong = _uses(s.nowplaying.npcontrols.shuffleSong, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.shuffleAlbum = _uses(s.nowplaying.npcontrols.shuffleAlbum, { w = smallControlWidth })
		
		s.nowplaying_large_art.npcontrols.volDown = _uses(s.nowplaying.npcontrols.volDown, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.volUp = _uses(s.nowplaying.npcontrols.volUp, { w = smallControlWidth })

		s.nowplaying_large_art.npcontrols.thumbsUp = _uses(s.nowplaying.npcontrols.thumbsUp, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.thumbsDown = _uses(s.nowplaying.npcontrols.thumbsDown, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.thumbsUpDisabled = _uses(s.nowplaying.npcontrols.thumbsUpDisabled, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.thumbsDownDisabled = _uses(s.nowplaying.npcontrols.thumbsDownDisabled, { w = smallControlWidth })

		s.nowplaying_large_art.npcontrols.love = _uses(s.nowplaying.npcontrols.love, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.hate = _uses(s.nowplaying.npcontrols.hate, { w = smallControlWidth })

		s.nowplaying_large_art.npcontrols.fwdDisabled = _uses(s.nowplaying.npcontrols.fwdDisabled, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.rewDisabled = _uses(s.nowplaying.npcontrols.rewDisabled, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.shuffleDisabled = _uses(s.nowplaying.npcontrols.shuffleDisabled, { w = smallControlWidth })
		s.nowplaying_large_art.npcontrols.repeatDisabled = _uses(s.nowplaying.npcontrols.repeatDisabled, { w = smallControlWidth })
	else
		s.nowplaying_large_art.npcontrols.div1 = _uses(_transportControlBorder, {
			w = _dp(6),
			padding = { GAP_2, 0, GAP_2, 0 }
		})

		s.nowplaying_large_art.npcontrols.div2 = _uses(s.nowplaying_large_art.npcontrols.div1)
		s.nowplaying_large_art.npcontrols.div3 = _uses(s.nowplaying_large_art.npcontrols.div1)
		s.nowplaying_large_art.npcontrols.div4 = _uses(s.nowplaying_large_art.npcontrols.div1)
		s.nowplaying_large_art.npcontrols.div5 = _uses(s.nowplaying_large_art.npcontrols.div1)
		s.nowplaying_large_art.npcontrols.div6 = _uses(s.nowplaying_large_art.npcontrols.div1)
	end

	s.nowplaying_large_art.npcontrols.pressed = {
		rew     = _uses(s.nowplaying_large_art.npcontrols.rew, { bgImg = keyMiddlePressed }),
		play    = _uses(s.nowplaying_large_art.npcontrols.play, { bgImg = keyMiddlePressed }),
		pause   = _uses(s.nowplaying_large_art.npcontrols.pause, { bgImg = keyMiddlePressed }),
		fwd     = _uses(s.nowplaying_large_art.npcontrols.fwd, { bgImg = keyMiddlePressed }),
		repeatPlaylist  = _uses(s.nowplaying_large_art.npcontrols.repeatPlaylist, { bgImg = keyMiddlePressed }),
		repeatSong      = _uses(s.nowplaying_large_art.npcontrols.repeatSong, { bgImg = keyMiddlePressed }),
		repeatOff       = _uses(s.nowplaying_large_art.npcontrols.repeatOff, { bgImg = keyMiddlePressed }),
		repeatMode      = _uses(s.nowplaying_large_art.npcontrols.repeatMode, { bgImg = keyMiddlePressed }),
		shuffleAlbum    = _uses(s.nowplaying_large_art.npcontrols.shuffleAlbum, { bgImg = keyMiddlePressed }),
		shuffleSong     = _uses(s.nowplaying_large_art.npcontrols.shuffleSong, { bgImg = keyMiddlePressed }),
		shuffleMode      = _uses(s.nowplaying_large_art.npcontrols.shuffleMode, { bgImg = keyMiddlePressed }),
		shuffleOff      = _uses(s.nowplaying_large_art.npcontrols.shuffleOff, { bgImg = keyMiddlePressed }),
		volDown = _uses(s.nowplaying_large_art.npcontrols.volDown, { bgImg = keyMiddlePressed }),
		volUp   = _uses(s.nowplaying_large_art.npcontrols.volUp, { bgImg = keyMiddlePressed }),

		thumbsUp    = _uses(s.nowplaying_large_art.npcontrols.thumbsUp, { bgImg = keyMiddlePressed }),
		thumbsDown  = _uses(s.nowplaying_large_art.npcontrols.thumbsDown, { bgImg = keyMiddlePressed }),
		thumbsUpDisabled    = s.nowplaying_large_art.npcontrols.thumbsUpDisabled,
		thumbsDownDisabled  = s.nowplaying_large_art.npcontrols.thumbsDownDisabled,
		love        = _uses(s.nowplaying_large_art.npcontrols.love, { bgImg = keyMiddlePressed }),
		hate        = _uses(s.nowplaying_large_art.npcontrols.hate, { bgImg = keyMiddlePressed }),
		fwdDisabled = _uses(s.nowplaying_large_art.npcontrols.fwdDisabled),
		rewDisabled = _uses(s.nowplaying_large_art.npcontrols.rewDisabled),
		shuffleDisabled = _uses(s.nowplaying_large_art.npcontrols.shuffleDisabled),
		repeatDisabled = _uses(s.nowplaying_large_art.npcontrols.repeatDisabled),
	}

	s.nowplaying_large_art.nptitle.pressed = _uses(s.nowplaying_large_art.nptitle)
	s.nowplaying_large_art.npalbumgroup.pressed = _uses(s.nowplaying_large_art.npalbumgroup)
	s.nowplaying_large_art.npartistgroup.pressed = _uses(s.nowplaying_large_art.npartistgroup)
	s.nowplaying_large_art.title.pressed = _uses(s.nowplaying_large_art.title, {
		text = {
			fg = { 0xB3, 0xB3, 0xB3 },
			sh = { },
			bgImg = pressedTitlebarButtonBox,
		}
	})
	s.nowplaying_large_art.npprogress.npprogressB_disabled = _uses(s.nowplaying_large_art.npprogress.npprogressB, {
		img = _songProgressBarDisabled,
	})

	s.nowplaying_art_only = _uses(s.nowplaying, {
		bgImg            = blackBackground,
		title            = { hidden = 1 },
		nptitle          = { hidden = 1 },
		npcontrols       = { hidden = 1 },
		npprogress       = { hidden = 1 },
		npprogressNB     = { hidden = 1 },
		npartistgroup    = { hidden = 1 },
		npalbumgroup     = { hidden = 1 },
		npartwork = {
			w = h,
			position = LAYOUT_NONE,
			x = (w - h) / 2,
			y = 0,
			align = "center",
			h = h,
			artwork = {
				w = h,
				align = "center",
				padding = 0,
				img = false,
			},
		},

		npvisu = { hidden = 1 },

	})
	s.nowplaying_art_only.pressed = _uses(s.nowplaying_art_only)

	s.nowplaying_text_only = _uses(s.nowplaying, {
		nptitle = {
			x = _dp(40),
			y = TITLE_HEIGHT + _dp(50),
			nptrack =  {
				w   = w - _dp(140),
			},
		},
		npartistgroup = {
			x = _dp(40),
			y = TITLE_HEIGHT + _dp(50) + _dp(65),
			npartist =  {
				w = w - _dp(65),
			},
		},
		npalbumgroup = {
			x = _dp(40),
			y = TITLE_HEIGHT + _dp(50) + _dp(60) + _dp(55),
			npalbum =  {
				w = w - _dp(65),
			},
		},
		npartwork = { hidden = 1 },

		npvisu = { hidden = 1 },

		npprogress = {
			position = LAYOUT_NONE,
			x = _dp(50),
			y = h - _dp(160),
			padding = { 0, GAP_10, 0, 0 },
			elapsed = {
				w = _dp(60),
				align = 'left',
				padding = { 0, 0, GAP_4, GAP_20 },
				font = _boldfont(FONT_SIZE_XS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			remain = {
				w = _dp(60),
				align = 'right',
				padding = { GAP_4, 0, 0, GAP_20 },
				font = _boldfont(FONT_SIZE_XS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			elapsedSmall = {
				w = _dp(60),
				align = 'left',
				padding = { 0, 0, GAP_4, GAP_20 },
				font = _boldfont(FONT_SIZE_XXS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			remainSmall = {
				w = _dp(60),
				align = 'right',
				padding = { GAP_4, 0, 0, GAP_20 },
				font = _boldfont(FONT_SIZE_XXS),
				fg = { 0xe7,0xe7, 0xe7 },
				sh = { 0x37, 0x37, 0x37 },
			},
			npprogressB = {
				w = w - 2*_dp(50) - 2*_dp(80),
				h = _dp(50),
				padding = { 0, 0, 0, 0 },
		        position = LAYOUT_CENTER,
				horizontal = 1,
				bgImg = _songProgressBackground,
				img = _songProgressBar,
			},
		},
		npprogressNB = {
			x = _dp(720),
			y = TITLE_HEIGHT + _dp(55),
			padding = { 0, 0, 0, 0 },
			position = LAYOUT_NONE,
		},
	})
	s.nowplaying_text_only.npprogress.npprogressB_disabled = _uses(s.nowplaying_text_only.npprogress.npprogressB, {
		img = _songProgressBarDisabled,
	})
	s.nowplaying_text_only.pressed = _uses(s.nowplaying_text_only)
	s.nowplaying_text_only.nptitle.pressed = _uses(s.nowplaying_text_only.nptitle)
	s.nowplaying_text_only.npalbumgroup.pressed = _uses(s.nowplaying_text_only.npalbumgroup)
	s.nowplaying_text_only.npartistgroup.pressed = _uses(s.nowplaying_text_only.npartistgroup)

	-- Visualizer: Container with titlebar, progressbar and controls.
	--  The space between title and controls is used for the visualizer.
	s.nowplaying_visualizer_common = _uses(s.nowplaying, {
		bgImg = blackBackground,

		npartistgroup = { hidden = 1 },
		npalbumgroup = { hidden = 1 },
		npartwork = { hidden = 1 },

		title = _uses(s.title, {
			zOrder = 1,
			h = TITLE_HEIGHT,
			text = {
				-- Hack: text needs to be there to fill the space, but is not visible
				padding = { w, 0, 0, 0 }
			},
		}),

		-- Drawn over regular text between buttons
		nptitle = { 
			zOrder = 2,
			position = LAYOUT_NONE,
			x = _dp(80),
			y = 0,
			h = TITLE_HEIGHT,
			border = { 0, 0 ,0, 0 },
			padding = { GAP_20, GAP_14, GAP_5, GAP_5 },
			nptrack = {
				align = "center",
				w = w - _dp(196),
			},
		},

		npartistalbum = {
			hidden = 0,
			zOrder = 2,
			position = LAYOUT_NONE,
			x = 0,
			y = TITLE_HEIGHT,
			w = w,
			h = _dp(60),
			bgImg = titleBox,
			align = "center",
			fg = { 0xb3, 0xb3, 0xb3 },
			padding = { GAP_100, 0, GAP_100, GAP_5 },
			font = _font(FONT_SIZE_S),
		},

		npprogress = {
			zOrder = 3,
			position = LAYOUT_NORTH,
			x = GAP_10,
			y = TITLE_HEIGHT + GAP_20,
			h = _dp(60),
			w = w - GAP_10 * 2,
			elapsed = {
				w = _dp(60),
			},
			remain = {
				w = _dp(60),
			},
			elapsedSmall = {
				w = _dp(60),
			},
			remainSmall = {
				w = _dp(60),
			},
			npprogressB = {
				h = WH_FILL,
				w = WH_FILL,
				zOrder = 10,
				position = LAYOUT_CENTER,
				border = { 0, 0, 0, 0 },
				padding = { 0, GAP_10, 0, GAP_10 },
				horizontal = 1,
				bgImg = false,
				img = _vizProgressBar,
				pillImg = _vizProgressBarPill,
			},
		},

		npprogressNB = {
			x = w - _dp(80),
			y = TITLE_HEIGHT + _dp(22),
			h = _dp(38),
		},
	})
	s.nowplaying_visualizer_common.npprogress.npprogressB_disabled = s.nowplaying_visualizer_common.npprogress.npprogressB

	-- Visualizer: Spectrum Visualizer
	s.nowplaying_spectrum_text = _uses(s.nowplaying_visualizer_common, {
		npvisu = {
			hidden = 0,
			position = LAYOUT_NORTH,
			x = GAP_20,
			y = 2 * TITLE_HEIGHT + _dp(4),
			w = w - GAP_20 * 2,
			h = h * 0.5,
			border = { 0, 0, 0, 0 },
			padding = { 0, 0, 0, 0 },

			spectrum = {
				position = LAYOUT_CENTER,
				x = 0,
				y = 0,
				w = WH_FILL,
				h = WH_FILL,
				border = { 0, 0, 0, 0 },
				padding = { 0, 0, 0, 0 },

				bg = { 0x00, 0x00, 0x00, 0x00 },

				barColor = { 0x14, 0xbc, 0xbc, 0xff },
				capColor = { 0x74, 0x56, 0xa1, 0xff },

				isMono = 0,				-- 0 / 1

				capHeight = { _dp(4), _dp(4) },			-- >= 0
				capSpace = { _dp(4), _dp(4) },			-- >= 0
				channelFlipped = { 0, 1 },		-- 0 / 1
				barsInBin = { _dp(2), _dp(2) },			-- > 1
				barWidth = { _dp(1), _dp(1) },			-- > 1
				barSpace = { _dp(3), _dp(3) },			-- >= 0
				binSpace = { _dp(6), _dp(6) },			-- >= 0
				clipSubbands = { _dp(1), _dp(1) },		-- 0 / 1
			}
		},
	})
	s.nowplaying_spectrum_text.pressed = _uses(s.nowplaying_spectrum_text)

	s.nowplaying_spectrum_text.title.pressed = _uses(s.nowplaying_spectrum_text.title, {
			text = {
			-- Hack: text needs to be there to fill the space, not visible
			padding = { w, 0, 0, 0 }
		},
	})

	-- Visualizer: Analog VU Meter
	s.nowplaying_vuanalog_text = _uses(s.nowplaying_visualizer_common, {
		npvisu = {
			hidden = 0,
			position = LAYOUT_NONE,
			x = 0,
			y = TITLE_HEIGHT + _dp(63),
			w = _dp(800),
			h = _dp(413) - (TITLE_HEIGHT + _dp(38) + _dp(38)),
			border = { 0, 0, 0, 0 },
			padding = { 0, 0, 0, 0 },

			vumeter_analog = {
				position = LAYOUT_NONE,
				x = 0,
				y = TITLE_HEIGHT + _dp(63),
				w = _dp(800),
				h = _dp(413) - (TITLE_HEIGHT + _dp(38) + _dp(38)),
				border = { 0, 0, 0, 0 },
				padding = { 0, 0, 0, 0 },
				bgImg = _loadImage(imgpath .. "UNOFFICIAL/VUMeter/vu_analog_25seq_w.png"),
			}
		},
	})
	s.nowplaying_vuanalog_text.pressed = _uses(s.nowplaying_vuanalog_text)

	s.nowplaying_vuanalog_text.title.pressed = _uses(s.nowplaying_vuanalog_text.title, {
		text = {
			-- Hack: text needs to be there to fill the space, not visible
			padding = { w, 0, 0, 0 }
		},
	})

	s.brightness_group = {
		order = {  'down', 'div1', 'slider', 'div2', 'up' },
		position = LAYOUT_SOUTH,
		h = _dp(56),
		w = WH_FILL,
		bgImg = sliderBackground,

		div1 = _uses(_transportControlBorder),
		div2 = _uses(_transportControlBorder),

		down   = _uses(_transportControlButton, {
			w = _dp(56),
			h = _dp(56),
			img = _loadImage(imgpath .. "Icons/icon_toolbar_brightness_down.png"),
		}),
		up   = _uses(_transportControlButton, {
			w = _dp(56),
			h = _dp(56),
			img = _loadImage(imgpath .. "Icons/icon_toolbar_brightness_up.png"),
		}),
	}
	s.brightness_group.pressed = {
		down   = _uses(s.brightness_group.down, { bgImg = sliderButtonPressed }),
		up   = _uses(s.brightness_group.up, { bgImg = sliderButtonPressed }),
	}

	s.brightness_slider = {
		w = WH_FILL,
		border = { GAP_5, 0, GAP_5, 0 },
		padding = { GAP_6, 0, GAP_6, 0 },
		position = LAYOUT_CENTER,
		horizontal = 1,
		bgImg = _volumeSliderBackground,
		img = _volumeSliderBar,
		pillImg = _volumeSliderPill,
	}

	s.settings_slider_group = _uses(s.brightness_group, {
		down = {
			img = _loadImage(imgpath .. "Icons/icon_toolbar_minus.png"),
		},
		up = {
			img = _loadImage(imgpath .. "Icons/icon_toolbar_plus.png"),
		},
	})

	s.settings_slider = _uses(s.brightness_slider, {
	})
	s.settings_slider_group.pressed = {
		down = _uses(s.settings_slider_group.down, { 
			bgImg = sliderButtonPressed,
			img = _loadImage(imgpath .. "Icons/icon_toolbar_minus_dis.png"),
		}),
		up = _uses(s.settings_slider_group.up, { 
			bgImg = sliderButtonPressed,
			img = _loadImage(imgpath .. "Icons/icon_toolbar_plus_dis.png"),
		}),
	}

	s.settings_volume_group = _uses(s.brightness_group, {
		down = {
			img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_down.png"),
		},
		up = {
			img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_up.png"),
		},
	})
	s.settings_volume_group.pressed = {
		down = _uses(s.settings_volume_group.down, { 
			bgImg = sliderButtonPressed,
			img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_down_dis.png"),
		}),
		up = _uses(s.settings_volume_group.up, { 
			bgImg = sliderButtonPressed,
			img = _loadImage(imgpath .. "Icons/icon_toolbar_vol_up_dis.png"),
		}),
	}

	s.debug_canvas = {
		zOrder = 9999
	}

	s.demo_text = {
		font = _boldfont(FONT_SIZE_XS),
		position = LAYOUT_SOUTH,
		w = w,
		h = _dp(50),
		align = 'center',
		padding = { GAP_6, 0, GAP_6, GAP_10 },
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
	}


	-- inheritable properties for child skins
	s.CONSTANTS = {
		skinSuffix = skinSuffix,
		fiveItemBox = fiveItemBox,
		fiveItemSelectionBox = fiveItemSelectionBox,
		fiveItemPressedBox = fiveItemPressedBox,
		threeItemSelectionBox = threeItemSelectionBox,
		threeItemPressedBox = threeItemPressedBox,
		smallSpinny = smallSpinny,
		largeSpinny = largeSpinny,
		addArrow = addArrow,
		
		CHECK_PADDING = CHECK_PADDING,
		MENU_ITEM_ICON_PADDING = MENU_ITEM_ICON_PADDING,
		TEXT_COLOR = TEXT_COLOR,
		TEXT_SH_COLOR = TEXT_SH_COLOR,
		TITLE_HEIGHT = TITLE_HEIGHT,
		ALBUMMENU_FONT_SIZE = FONT_SIZE_XS,
		ITEM_ICON_ALIGN = ITEM_ICON_ALIGN,
		FIVE_ITEM_HEIGHT = FIVE_ITEM_HEIGHT,
		NP_ARTISTALBUM_FONT_SIZE = FONT_SIZE_S,
		NP_TRACK_FONT_SIZE = FONT_SIZE_M,
		thisSkin = thisSkin,
		-- functions
		_uses = _uses,
		_font = _font,
		_boldfont = _boldfont,
		_loadImage = function(img) return _loadImage(img) end,
		_loadImageTile = function(img) return _loadImageTile(img) end,
	}

	return s

end


function npButtonSelectorShow(self)
	local window = Window("text_list", self:string('NOW_PLAYING_BUTTONS') )
	local menu = SimpleMenu("menu")
	local settings = self:getSettings()

	for i, v in ipairs(tbButtons) do
		menu:addItem( {
			text = self:string("NOW_PLAYING_BUTTON_" .. string.upper(v)),
			style = 'item_choice',
			check = Checkbox("checkbox", 
			function(object, isSelected)
				appletManager:callService("setNowPlayingScreenButtons", v, isSelected)
				jiveMain:reloadSkin()
			end,
			settings[v]),
		} )
	end

	window:addWidget(menu)
	window:show()
end

function setNowPlayingScreenButtons(self, button, isSelected)
	local settings = self:getSettings()
	settings[button] = isSelected
	self:storeSettings()
end

function getNowPlayingScreenButtons(self)
	return self:getSettings()
end

function buttonSettingsMenuItem(self)
	return {
		id = "npButtonSelector",
		iconStyle = "hm_advancedSettings",
		node = "screenSettingsNowPlaying",
		text = self:string("NOW_PLAYING_BUTTONS"),
		sound = "WINDOWSHOW",
		callback = function(event, menuItem)
			return self:npButtonSelectorShow() 
		end
	}
end

function skinCustom(self, s, reload, useDefaultSize)
	local screen_width, screen_height = Framework:getScreenSize()
	return self:skin(s, reload, useDefaultSize, screen_width, screen_height)
end

function free(self)
	jiveMain:removeItemById("npButtonSelector")
	return true
end

--[[

=head1 LICENSE

Copyright 2010 Logitech. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]]

