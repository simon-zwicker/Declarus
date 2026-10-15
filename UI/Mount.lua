
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Mount
-- Description: Mounts declarative views into World of Warcraft frames
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines the public mounting API
-- ============================================================================

---@class DeclarusMountHandle
---@field frame Frame

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Implementation
-- Description: Creates and renders a declarative view hierarchy
-- ============================================================================

---Mounts a declarative view into a WoW parent frame
---@param view DeclarusView
---@param parent Frame
---@return DeclarusMountHandle
function UI.Mount(view, parent)
    assert(view, "Mount requires a view")
    assert(parent, "Mount requires a parent frame")

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local host = CreateFrame("Frame", nil, parent)

    host:SetSize(arranged.width, arranged.height)
    host:SetPoint("CENTER", parent, "CENTER", 0, 0)

    local frame = UI._Render.Render(view, arranged, host)

    return {
        frame = frame,
    }
end