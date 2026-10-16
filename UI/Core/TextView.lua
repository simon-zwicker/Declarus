
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