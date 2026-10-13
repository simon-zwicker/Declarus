
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Types/Alignment
-- Description: Defines alignment options for UI layouts
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: References the DeclarusUI namespace
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Defines the available alignment values
-- ============================================================================

---@enum DeclarusAlignment
local Alignment = {
    Start = "STAR",
    Center = "CENTER",
    End = "END",
    Stretch = "STRETCH",
}

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the alignment values within DeclarusUI
-- ============================================================================

UI.Alignment = Alignment
