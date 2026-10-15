
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
    -- VStack
    Left = "LEFT",
    Right = "RIGHT",

    -- HStack
    Top = "TOP",
    Bottom = "BOTTOM",
    
    -- All Stacks
    Center = "CENTER",
    Stretch = "STRETCH",
}

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the alignment values within DeclarusUI
-- ============================================================================

UI.Alignment = Alignment
