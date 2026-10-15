
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Layout/VStack
-- Description: Defines the vertical stack layout component.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines local dependencies.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Creates vertical stack views.
-- ============================================================================

---Creates a vertical stack containing the specified children.
---@param children DeclarusView[]
---@return DeclarusStack
local function VStack(children)
    return UI._Stack.New("VStack", children)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers VStack within Declarus UI.
-- ============================================================================

UI.VStack = VStack