
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

---@class DeclarusArrangeEngine
local Arrange = {}

-- ============================================================================
-- Title:       Helpers
-- Description: Arrange helper functions
-- ============================================================================

---@param alignment DeclarusAlignment
---@param isHorizontal boolean
---@param available number
---@param childSize number
---@return number
local function GetAlignmentOffset(alignment, isHorizontal, available, childSize)
    local remaining = available - childSize

    if alignment == UI.Alignment.Center then
        return remaining / 2
    end

    if alignment == UI.Alignment.Bottom
        or alignment == UI.Alignment.Right then
        return remaining
    end

    return 0
end

---@param child DeclarusView
---@param measured DeclarusMeasuredSize
---@param isHorizontal boolean
---@param availableCrossSize number
---@return DeclarusMeasuredSize
local function GetStretchedSize(child, measured, isHorizontal, availableCrossSize)
    local property

    if isHorizontal then
        property = child.properties.height
    else
        property = child.properties.width
    end

    -- Explicit dimensions always take priority.
    if type(property) == "number" then
        return measured
    end

    local currentSize = isHorizontal
        and measured.height
        or measured.width

    local stretchedSize = math.max(currentSize, availableCrossSize)

    if stretchedSize == currentSize then
        return measured
    end

    -- Create a copy to preserve the original measurement.
    ---@type DeclarusMeasuredSize
    local result = {
        width = measured.width,
        height = measured.height,
        children = measured.children,
    }

    if isHorizontal then
        result.height = stretchedSize
    else
        result.width = stretchedSize
    end

    -- Recalculate descendants using the stretched dimensions.
    if child.kind == "HStack" or child.kind == "VStack" then
        local remeasured = UI._Measure.Measure(child, {
            width = result.width,
            height = result.height,
        })

        result.children = remeasured.children
    end

    return result
end

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

    local padding = view.properties.padding or {}

    local left = padding.left or 0
    local right = padding.right or 0
    local top = padding.top or 0
    local bottom = padding.bottom or 0

    local alignment = view.properties.alignment or (isHorizontal and UI.Alignment.Top or UI.Alignment.Left)

    local availableCrossSize

    if isHorizontal then
        availableCrossSize = measured.height - top - bottom
    else
        availableCrossSize = measured.width - left - right
    end

    local contentX = x + left
    local contentY = y + top

    local cursor = isHorizontal and contentX or contentY

    ---@type DeclarusArrangedSize[]
    local arrangedChildren = {}

    for index, child in ipairs(view.children) do
        local childMeasured = measured.children[index]

        local crossAxis = isHorizontal and "height" or "width"
        local childCrossProperty = child.properties[crossAxis]

        local shouldStretch = childCrossProperty == UI.Size.Fill
            or alignment == UI.Alignment.Stretch
            or (
                child.kind == "HStack"
                and childCrossProperty == nil
                and not isHorizontal
            )

        if shouldStretch then
            childMeasured = GetStretchedSize(
                child,
                childMeasured,
                isHorizontal,
                availableCrossSize
            )
        end

        local childCrossSize = isHorizontal
            and childMeasured.height
            or childMeasured.width

        local offset = GetAlignmentOffset(
            alignment,
            isHorizontal,
            availableCrossSize,
            childCrossSize
        )

        local childX = isHorizontal and cursor or contentX + offset
        local childY = isHorizontal and contentY + offset or cursor

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

    if view.kind == "ScrollView" then
        local result = ArrangeView(view, measured, x, y)
        local padding = view.properties.padding or {}
        result.children[1] = Arrange.Arrange(view.children[1], measured.children[1],
            x + (padding.left or 0), y + (padding.top or 0))
        return result
    end
    return ArrangeView(view, measured, x, y)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the arrange engine.
-- ============================================================================

UI._Arrange = Arrange