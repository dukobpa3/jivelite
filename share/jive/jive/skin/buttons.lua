local Group = require("jive.ui.Group")
local Icon = require("jive.ui.Icon")
local Label = require("jive.ui.Label")

local M = {}

function M.GetButton(style)
    return Group(style, {
        icon = Icon("icon"),
        icon_text = Label("text"),
    })
end


return M