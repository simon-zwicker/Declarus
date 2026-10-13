
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Types/Size
-- Description: Defines sizing options for UI elements.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: References the DeclarusUI namespace
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Defines the available sizing values
-- ============================================================================

---@enum DeclarusSize
local Size = {
    Wrap = "WRAP",
    Fill = "FILL",
}

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the sizing values within DeclarusUI
-- ============================================================================

UI.Size = Size