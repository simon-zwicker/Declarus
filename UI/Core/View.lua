
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Core/View
-- Description: Defines the base structure for Declarus UI views
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines the base view types and properties
-- ============================================================================

---@class DeclarusPadding
---@field left number
---@field right number
---@field top number
---@field bottom number

---@alias DeclarusTextureLayer 'BACKGROUND'|'BORDER'|'ARTWORK'|'OVERLAY'|'HIGHLIGHT'

---@class DeclarusTexCoords
---@field left number
---@field right number
---@field top number
---@field bottom number

---@alias DeclarusGradientOrientation 'HORIZONTAL'|'VERTICAL'

---@class DeclarusGradient
---@field orientation DeclarusGradientOrientation
---@field fromColor DeclarusColor
---@field toColor DeclarusColor

---@class DeclarusViewProperties
---@field width? number|DeclarusSize
---@field height? number|DeclarusSize
---@field padding? DeclarusPadding
---@field backgroundColor? DeclarusColor
---@field foregroundColor? DeclarusColor
---@field gradient? DeclarusGradient
---@field texture? string|number
---@field texCoords? DeclarusTexCoords
---@field textureTint? DeclarusColor
---@field textureLayer? DeclarusTextureLayer
---@field textureSublevel? number
---@field opacity? number
---@field visible? boolean
---@field localization? DeclarusLocalization

---@class DeclarusView
---@field kind string
---@field properties DeclarusViewProperties
---@field children DeclarusView[]
---@field width fun<T>(self: T, value: number|DeclarusSize): T
---@field height fun<T>(self: T, value: number|DeclarusSize): T
---@field size fun<T>(self: T, width: number|DeclarusSize, height: number|DeclarusSize): T
---@field padding fun<T>(self: T, edge: DeclarusEdge|number, value?: number): T
---@field gradient fun<T>(self: T, orientation?: DeclarusGradientOrientation, fromColor?: DeclarusColor, toColor?: DeclarusColor): T
---@field texture fun<T>(self: T, source: string|number): T
---@field texCoords fun<T>(self: T, left: number, right: number, top: number, bottom: number): T
---@field textureTint fun<T>(self: T, color: DeclarusColor): T
---@field textureLayer fun<T>(self: T, layer: DeclarusTextureLayer, sublevel?: number): T
---@field backgroundColor fun<T>(self: T, color: DeclarusColor): T
---@field foregroundColor fun<T>(self: T, color: DeclarusColor): T
---@field opacity fun<T>(self: T, value: number): T
---@field visible fun<T>(self: T, value: boolean): T

---@class DeclarusViewClass
---@field New fun(kind: string, children?: DeclarusView[]): DeclarusView

-- ============================================================================
-- Title:       Locals
-- Description: Defines local dependencies and the view prototype
-- ============================================================================

local UI = _G.Declarus.UI
local View = {}

local EDGE_SIDES = {
    [UI.Edge.All] = { "top", "bottom", "left", "right" },
    [UI.Edge.Horizontal] = { "left", "right" },
    [UI.Edge.Vertical] = { "top", "bottom" },
    [UI.Edge.Top] = { "top" },
    [UI.Edge.Bottom] = { "bottom" },
    [UI.Edge.Left] = { "left" },
    [UI.Edge.Right] = { "right" },
}

-- ============================================================================
-- Title:       Implementation
-- Description: Implements the base view structure and constructor
-- ============================================================================

View.__index = View

---Creates a new declarative view description
---@param kind string
---@param children? DeclarusView[]
---@return DeclarusView
function View.New(kind, children)
    ---@type DeclarusView
    local instance = setmetatable({
        kind = kind,
        properties = {},
        children = children or {},
    }, View)

    return instance
end

-- ============================================================================
-- Title:       Layout Modifiers
-- Description: Configures dimensions and spacing for declarative views
-- ============================================================================

---Sets the width of the view.
---@generic T: DeclarusView
---@param self T
---@param value number|DeclarusSize
---@return T
function View:width(value)
    self.properties.width = value
    return self
end

---Sets the height of the view.
---@generic T: DeclarusView
---@param self T
---@param value number|DeclarusSize
---@return T
function View:height(value)
    self.properties.height = value
    return self
end

---Sets the size (width, height) of the view
---@generic T: DeclarusView
---@param self T
---@param width number|DeclarusSize
---@param height number|DeclarusSize
---@return T
function View:size(width, height)
    return self
        :width(width)
        :height(height)
end

---Adds padding to the specified edges of the view
---@generic T: DeclarusView
---@param self T
---@param edge DeclarusEdge|number
---@param value? number
---@return T
function View:padding(edge, value)
    if type(edge) == "number" then
        value = edge
        edge = UI.Edge.All
    end

    assert(type(value) == "number", "Padding value must be a number")

    local sides = EDGE_SIDES[edge]
    assert(sides, "Invalid padding edge")

    local padding = self.properties.padding or {
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
    }

    for _, side in ipairs(sides) do
        padding[side] = padding[side] + value
    end

    self.properties.padding = padding

    return self
end

-- ============================================================================
-- Title:       Appearance Modifiers
-- Description: Configures the visual appearance of declarative views
-- ============================================================================

---Sets the background color of the view
---@generic T: DeclarusView
---@param self T
---@param color DeclarusColor
---@return T
function View:backgroundColor(color)
    self.properties.backgroundColor = color
    return self
end

---Sets the foreground color of the view
---@generic T: DeclarusView
---@param self T
---@param color DeclarusColor
---@return T
function View:foregroundColor(color)
    self.properties.foregroundColor = color
    return self
end

---Sets the opacity of the view.
---@generic T: DeclarusView
---@param self T
---@param value number
---@return T
function View:opacity(value)
    self.properties.opacity = value
    return self
end

---Sets the visibility of the view.
---@generic T: DeclarusView
---@param self T
---@param value boolean
---@return T
function View:visible(value)
    self.properties.visible = value
    return self
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the internal view prototype within DeclarusUI
-- ============================================================================

---Uses a texture file path or file ID, stretched over the view.
---@generic T: DeclarusView
---@param self T
---@param source string|number
---@return T
function View:texture(source)
    assert(type(source) == "string" or type(source) == "number", "Texture source required")
    self.properties.texture = source
    return self
end

-- Texture modifiers affect the image only, not padding, layout or text color.
local TEXTURE_LAYERS = {BACKGROUND = true, BORDER = true, ARTWORK = true, OVERLAY = true, HIGHLIGHT = true}

---@param value any
---@return boolean
local function normalized(value)
    return type(value) == "number" and value >= 0 and value <= 1
end

---@param color DeclarusColor
---@return DeclarusColor
local function copyColor(color)
    assert(type(color) == "table" and normalized(color[1]) and normalized(color[2])
        and normalized(color[3]) and (color[4] == nil or normalized(color[4])),
        "Color requires normalized RGB or RGBA channels")
    return {color[1], color[2], color[3], color[4] or 1}
end

---Selects normalized UV coordinates. Reversed edges mirror the texture.
---@generic T: DeclarusView
---@param self T
---@param left number
---@param right number
---@param top number
---@param bottom number
---@return T
function View:texCoords(left, right, top, bottom)
    assert(normalized(left) and normalized(right) and normalized(top) and normalized(bottom),
        "TexCoords must be numbers between 0 and 1")
    self.properties.texCoords = {left = left, right = right, top = top, bottom = bottom}
    return self
end

---Multiplies the texture's RGBA channels; white keeps the original image.
---@generic T: DeclarusView
---@param self T
---@param color DeclarusColor
---@return T
function View:textureTint(color)
    self.properties.textureTint = copyColor(color)
    return self
end

---Overrides the default BORDER layer. Higher layers/sublevels draw later.
---@generic T: DeclarusView
---@param self T
---@param layer DeclarusTextureLayer
---@param sublevel? number
---@return T
function View:textureLayer(layer, sublevel)
    if sublevel == nil then sublevel = 0 end
    assert(TEXTURE_LAYERS[layer], "Invalid texture draw layer")
    assert(type(sublevel) == "number" and sublevel >= -8 and sublevel <= 7
        and sublevel == math.floor(sublevel), "Texture sublevel must be an integer from -8 to 7")
    self.properties.textureLayer = layer
    self.properties.textureSublevel = sublevel
    return self
end

---Colors the view's image, or a white surface when no texture is set.
---Horizontal: left to right. Vertical: bottom to top. Nil clears the gradient.
---@generic T: DeclarusView
---@param self T
---@param orientation? DeclarusGradientOrientation
---@param fromColor? DeclarusColor
---@param toColor? DeclarusColor
---@return T
function View:gradient(orientation, fromColor, toColor)
    if orientation == nil then
        assert(fromColor == nil and toColor == nil, "Clearing a gradient takes no colors")
        self.properties.gradient = nil
        return self
    end
    assert(orientation == "HORIZONTAL" or orientation == "VERTICAL", "Invalid gradient orientation")
    assert(fromColor and toColor, "Gradient requires two colors")
    local from = copyColor(fromColor)
    local to = copyColor(toColor)
    self.properties.gradient = {orientation = orientation, fromColor = from, toColor = to}
    return self
end

---@cast View DeclarusViewClass
UI._View = View
