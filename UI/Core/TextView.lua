
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Core/TextView
-- Description: Shared base for text-based UI components
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- ============================================================================

---@class DeclarusTextViewProperties: DeclarusViewProperties
---@field font? string
---@field fontFlags? string
---@field fontSize? number
---@field text? string
---@field localization? DeclarusLocalization

---@class DeclarusTextView: DeclarusView
---@field properties DeclarusTextViewProperties
---@field localize fun(self: DeclarusTextView, localization: DeclarusLocalization): DeclarusTextView

-- ============================================================================
-- Title:       Locals
-- ============================================================================

local UI = _G.Declarus.UI
local View = UI._View

-- ============================================================================
-- Title:       TextView
-- ============================================================================

---@class DeclarusTextView
local TextView = {}

TextView.__index = TextView

setmetatable(TextView, {
    __index = View,
})

-- ============================================================================
-- Title:       Constructor
-- ============================================================================

---Creates a text-based view.
---@param kind string
---@return DeclarusTextView
function TextView.New(kind)
    local view = View.New(kind)

    ---@cast view DeclarusTextView
    return setmetatable(view, TextView)
end

-- ============================================================================
-- Title:       Localization
-- ============================================================================

---Assigns a localization provider to the text-based view.
---@param localization DeclarusLocalization
---@return DeclarusTextView
function TextView:localize(localization)
    self.properties.localization = localization

    return self
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

UI._TextView = TextView
---Sets the font file and optional WoW font flags.
---@param path string
---@param flags? string
---@return DeclarusTextView
function TextView:font(path, flags)
    assert(type(path) == "string" and path ~= "", "Font path required")
    self.properties.font = path
    self.properties.fontFlags = flags
    return self
end

---@param size number
---@return DeclarusTextView
function TextView:fontSize(size)
    assert(type(size) == "number" and size > 0, "Font size must be positive")
    self.properties.fontSize = size
    return self
end
