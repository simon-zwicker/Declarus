
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Engine/Render
-- Description: Renders declarative layouts into World of Warcraft frames.
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines the rendering engine.
-- ============================================================================

---@class DeclarusRenderEngine
---@field Render fun(view: DeclarusView, arranged: DeclarusArrangedSize, parent: Frame): Frame

-- ============================================================================
-- Title:       Locals
-- Description: References Declarus UI components.
-- ============================================================================

local UI = _G.Declarus.UI

---@class DeclarusRenderEngine
local Render = {}

-- ============================================================================
-- Title:       Helpers
-- Description: Rendering helper functions.
-- ============================================================================

---Applies the background color of a view.
---@param frame Frame
---@param view DeclarusView
local function ApplyBackground(frame, view)
    local color = view.properties.backgroundColor

    if not color then
        return
    end

    local texture = frame:CreateTexture(nil, "BACKGROUND")

    texture:SetAllPoints(frame)
    texture:SetColorTexture(
        color[1],
        color[2],
        color[3],
        color[4]
    )
end

---@param frame Frame
---@param view DeclarusTextView
local function RenderText(frame, view)
    local properties = view.properties

    local text = UI._LocalizationResolver.Resolve(
        properties.text or "",
        properties.localization
    )

    local fontString = frame:CreateFontString(nil, "ARTWORK")

    fontString:SetFont("Fonts\\FRIZQT__.TTF", 16)
    fontString:SetText(text)

    fontString:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        0,
        0
    )
end

---Creates a WoW frame for a declarative view.
---@param view DeclarusView
---@param arranged DeclarusArrangedSize
---@param parent Frame
---@param parentArranged? DeclarusArrangedSize
---@return Frame
local function RenderView(view, arranged, parent, parentArranged)
    local frame = CreateFrame("Frame", nil, parent)

    local relativeX = arranged.x
    local relativeY = arranged.y

    if parentArranged then
        relativeX = relativeX - parentArranged.x
        relativeY = relativeY - parentArranged.y
    end

    frame:SetSize(arranged.width, arranged.height)

    frame:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        relativeX,
        -relativeY
    )

    if view.kind == "Text" then
        ---@cast view DeclarusTextView
        RenderText(frame, view)
    end

    ApplyBackground(frame, view)

    for index, child in ipairs(view.children) do
        RenderView(
            child,
            arranged.children[index],
            frame,
            arranged
        )
    end

    return frame
end

-- ============================================================================
-- Title:       Implementation
-- Description: Converts arranged views into WoW frames.
-- ============================================================================

---Renders a declarative view tree into a WoW parent frame.
---@param view DeclarusView
---@param arranged DeclarusArrangedSize
---@param parent Frame
---@return Frame
function Render.Render(view, arranged, parent)
    assert(parent, "Render requires a parent frame")

    return RenderView(view, arranged, parent)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the rendering engine.
-- ============================================================================

UI._Render = Render