# Icon Utility Wrapper

A utility module for easy access to Material Design icons with different styles in JiveLite.

## Overview

The `jive.utils.icon` module provides a simple interface for using Material Design icons in your JiveLite applications. It supports all five Material Design icon styles:

- **Regular** - Filled icons
- **Outlined** - Outlined icons  
- **Round** - Rounded filled icons
- **Sharp** - Sharp-edged filled icons
- **Two-Tone** - Two-tone filled icons

## Installation

The icon fonts are already included in the project at:
```
jivelite/share/jive/icons/
├── Material_Icons/
├── Material_Icons_Outlined/
├── Material_Icons_Round/
├── Material_Icons_Sharp/
└── Material_Icons_Two_Tone/
```

## Usage

### Basic Usage

```lua
local icon = require("jive.utils.icon")

-- Create a play icon
local playIcon = icon.create("play_arrow", "regular", 24)

-- Create an outlined home icon
local homeIcon = icon.create("home", "outlined", 32)

-- Create a round settings icon
local settingsIcon = icon.create("settings", "round", 28)
```

### Convenience Functions

For each icon style, there's a convenience function:

```lua
-- Regular icons
local playIcon = icon.regular("play_arrow", 24)

-- Outlined icons
local homeIcon = icon.outlined("home", 32)

-- Round icons
local settingsIcon = icon.round("settings", 28)

-- Sharp icons
local closeIcon = icon.sharp("close", 24)

-- Two-tone icons
local starIcon = icon.twoTone("star", 32)
```

### Positioned Icons

Create icons with positioning (similar to `skin.icon()`):

```lua
local positionedIcon = icon.icon(10, 20, "play_arrow", "regular", 24)
-- Returns: { x = 10, y = 20, img = surface, layer = LAYER_FRAME, position = LAYOUT_SOUTH }
```

### Direct Font Access

Load icon fonts directly for custom rendering:

```lua
local iconFont = icon.font("regular", 24)
local iconWidth = iconFont:width("play_arrow")
local iconHeight = iconFont:height()
```

### Utility Functions

```lua
-- Get all available icon styles
local styles = icon.getAvailableStyles()
-- Returns: {"regular", "outlined", "round", "sharp", "two_tone"}

-- Clear the font cache to free memory
icon.clearCache()
```

## API Reference

### `icon.create(iconName, style, size)`

Creates an Icon widget with the specified Material Design icon.

**Parameters:**
- `iconName` (string) - Material Design icon name (e.g., "play_arrow", "home")
- `style` (string, optional) - Icon style: "regular", "outlined", "round", "sharp", "two_tone" (default: "regular")
- `size` (number, optional) - Font size in pixels (default: 24)

**Returns:** Icon widget

### `icon.icon(x, y, iconName, style, size)`

Creates an icon configuration table with positioning.

**Parameters:**
- `x` (number) - X coordinate
- `y` (number) - Y coordinate  
- `iconName` (string) - Material Design icon name
- `style` (string, optional) - Icon style (default: "regular")
- `size` (number, optional) - Font size (default: 24)

**Returns:** Table with icon configuration

### `icon.font(style, size)`

Loads an icon font with caching.

**Parameters:**
- `style` (string, optional) - Icon style (default: "regular")
- `size` (number, optional) - Font size (default: 24)

**Returns:** Font object

### Convenience Functions

- `icon.regular(iconName, size)` - Create regular icon
- `icon.outlined(iconName, size)` - Create outlined icon
- `icon.round(iconName, size)` - Create round icon
- `icon.sharp(iconName, size)` - Create sharp icon
- `icon.twoTone(iconName, size)` - Create two-tone icon

## Common Icon Names

Here are some commonly used Material Design icon names:

### Media Controls
- `play_arrow`, `pause`, `stop`, `skip_next`, `skip_previous`
- `volume_up`, `volume_down`, `volume_off`, `volume_mute`

### Navigation
- `home`, `menu`, `close`, `arrow_back`, `arrow_forward`
- `search`, `settings`, `account_circle`

### Actions
- `add`, `remove`, `edit`, `delete`, `save`
- `favorite`, `star`, `heart`, `thumb_up`, `thumb_down`
- `download`, `upload`, `share`, `print`, `email`

### Communication
- `phone`, `message`, `notifications`, `email`
- `wifi`, `bluetooth`, `gps_fixed`, `location_on`

### Time & Date
- `calendar_today`, `schedule`, `access_time`

### Files & Media
- `folder`, `file`, `image`, `video_library`, `music_note`

## Performance Notes

- Icon fonts are cached by style and size for better performance
- Use `icon.clearCache()` to free memory when needed
- The utility automatically handles font loading and surface creation

## Example Integration

```lua
-- In your applet
local icon = require("jive.utils.icon")

function createPlayButton()
    local playIcon = icon.create("play_arrow", "regular", 24)
    local button = Button("button", playIcon)
    return button
end

function createHomeMenu()
    local menuItems = {
        { text = "Home", icon = icon.regular("home", 24) },
        { text = "Settings", icon = icon.outlined("settings", 24) },
        { text = "Search", icon = icon.round("search", 24) }
    }
    return menuItems
end
```

## License

The Material Design icons are licensed under the Apache License 2.0. See the LICENSE.txt files in each icon directory for details. 