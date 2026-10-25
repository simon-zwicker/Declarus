-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Engine/Measure
-- Description: Calculates the required size of declarative views.
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines the calculated size of a view.
-- ============================================================================

---@class DeclarusSize2D
---@field width number
---@field height number

---@class DeclarusMeasuredSize: DeclarusSize2D
---@field children DeclarusMeasuredSize[]

---@class DeclarusMeasureEngine
---@field Measure fun(view: DeclarusView, availableSize?: DeclarusSize2D): DeclarusMeasuredSize

-- ============================================================================
-- Title:       Locals
-- Description: References the Declarus UI namespace.
-- ============================================================================

local UI = _G.Declarus.UI
local Measure = {}

-- ============================================================================
-- Title:       Implementation
-- Description: Measures views using a shared stack layout algorithm.
-- ============================================================================

---@param view DeclarusView
---@param availableSize? DeclarusSize2D
---@return DeclarusMeasuredSize
local function MeasureView(view, availableSize)
    local properties = view.properties

    local padding = properties.padding or {
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
    }

    ---@type number
    local width = padding.left + padding.right

    ---@type number
    local height = padding.top + padding.bottom

    local explicitWidth = properties.width
    local explicitHeight = properties.height

    if view.kind == "Text" then
        ---@cast view DeclarusTextView
        local textSize = UI._TextMeasure.Measure(view)

        width = width + textSize.width
        height = height + textSize.height
    end

    if type(explicitWidth) == "number" then
        width = explicitWidth
    elseif explicitWidth == UI.Size.Fill and availableSize then
        width = availableSize.width
    end

    if type(explicitHeight) == "number" then
        height = explicitHeight
    elseif explicitHeight == UI.Size.Fill and availableSize then
        height = availableSize.height
    end

    return {
        width = width,
        height = height,
        children = {},
    }
end

---@param view DeclarusStack
---@param availableSize? DeclarusSize2D
---@return DeclarusMeasuredSize
local function MeasureStack(view, availableSize)
    local properties = view.properties
    local children = view.children

    local padding = properties.padding or {
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
    }

    local isHorizontal = view.kind == "HStack"

    local mainAxis = isHorizontal and "width" or "height"
    local crossAxis = isHorizontal and "height" or "width"

    local mainPadding = isHorizontal
        and padding.left + padding.right
        or padding.top + padding.bottom

    local crossPadding = isHorizontal
        and padding.top + padding.bottom
        or padding.left + padding.right

    local spacing = properties.spacing or 0
    local totalSpacing = math.max(0, #children - 1) * spacing

    local explicitMain = properties[mainAxis]
    local explicitCross = properties[crossAxis]

    local availableMain = nil

    if type(explicitMain) == "number" then
        availableMain = explicitMain - mainPadding
    elseif explicitMain == UI.Size.Fill and availableSize then
        availableMain = availableSize[mainAxis] - mainPadding
    elseif explicitMain == nil and availableSize then
        availableMain = availableSize[mainAxis] - mainPadding
    end

    local fixedSize = 0
    local crossSize = 0
    local fillCount = 0
    local largestSibling = 0

    ---@type DeclarusMeasuredSize[]
    local measuredChildren = {}

    -- Measure fixed and wrapping children.
    for index, child in ipairs(children) do
        if child.properties[mainAxis] == UI.Size.Fill then
            fillCount = fillCount + 1
        else
            local childAvailable = nil

            if child.properties[crossAxis] == UI.Size.Fill then
                local availableCross = nil

                if type(explicitCross) == "number" then
                    availableCross = explicitCross - crossPadding
                elseif availableSize then
                    availableCross = availableSize[crossAxis] - crossPadding
                end

                if availableCross then
                    childAvailable = {
                        width = 0,
                        height = 0,
                    }

                    childAvailable[crossAxis] = math.max(0, availableCross)
                end
            end

            local size = Measure.Measure(child, childAvailable)

            measuredChildren[index] = size

            fixedSize = fixedSize + size[mainAxis]
            largestSibling = math.max(largestSibling, size[mainAxis])
            crossSize = math.max(crossSize, size[crossAxis])
        end
    end

    -- Find the largest intrinsic size among all Fill children.
    if not availableMain then
        for _, child in ipairs(children) do
            if child.properties[mainAxis] == UI.Size.Fill then
                local intrinsicSize = Measure.Measure(child)

                largestSibling = math.max(
                    largestSibling,
                    intrinsicSize[mainAxis]
                )
            end
        end
    end

    -- Distribute remaining space between Fill children.
    local fillSize = largestSibling

    if fillCount > 0 and availableMain then
        local remaining = math.max(
            0,
            availableMain - fixedSize - totalSpacing
        )

        fillSize = remaining / fillCount
    end

    -- Measure Fill children with their allocated size.
    for index, child in ipairs(children) do
        if child.properties[mainAxis] == UI.Size.Fill then
            local childAvailable = {
                width = availableSize and availableSize.width or 0,
                height = availableSize and availableSize.height or 0,
            }

            childAvailable[mainAxis] = fillSize

            local size = Measure.Measure(child, childAvailable)

            measuredChildren[index] = size
            crossSize = math.max(crossSize, size[crossAxis])
        end
    end

    local mainSize = fixedSize + totalSpacing

    for index, child in ipairs(children) do
        if child.properties[mainAxis] == UI.Size.Fill then
            mainSize = mainSize + measuredChildren[index][mainAxis]
        end
    end
    
    local measuredMain = mainSize + mainPadding
    local measuredCross = crossSize + crossPadding

    if type(explicitMain) == "number" then
        measuredMain = explicitMain
    elseif explicitMain == UI.Size.Fill and availableSize then
        measuredMain = availableSize[mainAxis]
    end

    if type(explicitCross) == "number" then
        measuredCross = explicitCross
    elseif explicitCross == UI.Size.Fill and availableSize then
        measuredCross = availableSize[crossAxis]
    end

    local width = isHorizontal and measuredMain or measuredCross
    local height = isHorizontal and measuredCross or measuredMain

    return {
        width = width,
        height = height,
        children = measuredChildren,
    }
end

---@param view DeclarusView
---@param availableSize? DeclarusMeasuredSize
---@return DeclarusMeasuredSize
function Measure.Measure(view, availableSize)
    if view.kind == "HStack" or view.kind == "VStack" then
        ---@cast view DeclarusStack
        return MeasureStack(view, availableSize)
    end

    if view.kind == "ScrollView" then
        local size = MeasureView(view, availableSize)
        local padding = view.properties.padding or {}
        size.children[1] = Measure.Measure(view.children[1], {
            width = math.max(0, size.width - (padding.left or 0) - (padding.right or 0)),
            height = 0,
        })
        return size
    end
    return MeasureView(view, availableSize)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the measurement engine within Declarus UI.
-- ============================================================================

UI._Measure = Measure