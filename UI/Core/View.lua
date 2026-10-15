
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

---@class DeclarusViewProperties
---@field width? number|DeclarusSize
---@field height? number|DeclarusSize
---@field padding? DeclarusPadding
---@field backgroundColor? DeclarusColor
---@field foregroundColor? DeclarusColor
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

---@cast View DeclarusViewClass

UI._View = View