
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Components/Text
-- Description: Declarative text component
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- ============================================================================

local UI = _G.Declarus.UI
local TextView = UI._TextView

-- ============================================================================
-- Title:       Text
-- ============================================================================

---Creates a declarative text view.
---@param value string
---@return DeclarusTextView
function UI.Text(value)
    assert(type(value) == "string", "Text requires a string")

    local view = TextView.New("Text")

    view.properties.text = value

    return view
end