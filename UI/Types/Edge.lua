
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Types/Edge
-- Description: Defines edge options for UI layouts
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: References the DeclarusUI namespace
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Defines the available edge values
-- ============================================================================

---@enum DeclarusEdge
local Edge = {
    All = "ALL",
    Top = "TOP",
    Bottom = "BOTTOM",
    Left = "LEFT",
    Right = "RIGHT",
    Horizontal = "HORIZONTAL",
    Vertical = "VERTICAL",
}

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the edge values within DeclarusUI
-- ============================================================================

UI.Edge = Edge