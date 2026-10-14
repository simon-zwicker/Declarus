
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Layout/HStack
-- Description: Defines the horizontal stack layout component
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines local dependencies
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Creates horizontal stack views
-- ============================================================================

---Creates a horizontal stack containing the specified children
---@param children DeclarusView[]
---@return DeclarusStack
local function HStack(children)
    return UI._Stack.New("HStack", children)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers HStack within DeclarusUI
-- ============================================================================

UI.HStack = HStack

