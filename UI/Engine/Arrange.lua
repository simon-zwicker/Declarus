
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Engine/Arrange
-- Description: Calculates positions for measured declarative layouts.
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines arranged layout structures.
-- ============================================================================

---@class DeclarusArrangedSize: DeclarusSize2D
---@field x number
---@field y number
---@field children DeclarusArrangedSize[]

---@class DeclarusArrangeEngine
---@field Arrange fun(view: DeclarusView, measured: DeclarusMeasuredSize, x?: number, y?: number): DeclarusArrangedSize

-- ============================================================================
-- Title:       Locals
-- Description: References Declarus UI components.
-- ============================================================================

local UI = _G.Declarus.UI

---@type DeclarusArrangeEngine
local Arrange = {}

-- ============================================================================
-- Title:       Implementation
-- Description: Calculates positions recursively.
-- ============================================================================

---@param view DeclarusView
---@param measured DeclarusMeasuredSize
---@param x number
---@param y number
---@return DeclarusArrangedSize
local function ArrangeView(view, measured, x, y)
    return {
        x = x,
        y = y,
        width = measured.width,
        height = measured.height,
        children = {},
    }
end

---@param view DeclarusStack
---@param measured DeclarusMeasuredSize
---@param x number
---@param y number
---@return DeclarusArrangedSize
local function ArrangeStack(view, measured, x, y)
    local isHorizontal = view.kind == "HStack"
    local spacing = view.properties.spacing or 0

    local cursor = isHorizontal and x or y

    ---@type DeclarusArrangedSize[]
    local arrangedChildren = {}

    for index, child in ipairs(view.children) do
        local childMeasured = measured.children[index]

        local childX = isHorizontal and cursor or x
        local childY = isHorizontal and y or cursor

        local arranged = Arrange.Arrange(
            child,
            childMeasured,
            childX,
            childY
        )

        arrangedChildren[index] = arranged

        cursor = cursor
            + (isHorizontal and childMeasured.width or childMeasured.height)
            + spacing
    end

    return {
        x = x,
        y = y,
        width = measured.width,
        height = measured.height,
        children = arrangedChildren,
    }
end

---@param view DeclarusView
---@param measured DeclarusMeasuredSize
---@param x? number
---@param y? number
---@return DeclarusArrangedSize
function Arrange.Arrange(view, measured, x, y)
    x = x or 0
    y = y or 0

    if view.kind == "HStack" or view.kind == "VStack" then
        ---@cast view DeclarusStack
        return ArrangeStack(view, measured, x, y)
    end

    return ArrangeView(view, measured, x, y)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the arrange engine.
-- ============================================================================

UI._Arrange = Arrange