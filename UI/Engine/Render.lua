
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

    local fontString = frame:CreateFontString(nil, "OVERLAY")

    fontString:SetFont(UI._FontResolver.Resolve(properties))
    fontString:SetText(text)

    local padding = properties.padding or {}
    local color = properties.foregroundColor
    if color then fontString:SetTextColor(unpack(color)) end

    fontString:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        padding.left or 0,
        -(padding.top or 0)
    )
end

---Creates a WoW frame for a declarative view.
---@param view DeclarusView
---@param arranged DeclarusArrangedSize
---@param parent Frame
---@param parentArranged? DeclarusArrangedSize
---@return Frame
local function RenderView(view, arranged, parent, parentArranged)
    local frame = CreateFrame(UI._ControlRender.FrameType(view), nil, parent)

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

    if view.kind == "Text" or view.kind == "Button" then
        ---@cast view DeclarusTextView
        RenderText(frame, view)
    end

    UI._ControlRender.Apply(frame, view)
    ApplyBackground(frame, view)
    _G.Declarus.WoW._ApplyTooltip(frame, view)
    if view.properties.texture or view.properties.gradient then
        local properties = view.properties
        local texture = frame:CreateTexture(nil, properties.textureLayer or "BORDER")
        texture:SetDrawLayer(properties.textureLayer or "BORDER", properties.textureSublevel or 0)
        texture:SetAllPoints(frame)
        if properties.texture then texture:SetTexture(properties.texture)
        else texture:SetColorTexture(1, 1, 1, 1) end
        local coords = properties.texCoords
        if coords then texture:SetTexCoord(coords.left, coords.right, coords.top, coords.bottom) end
        local tint = properties.textureTint
        local gradient = properties.gradient
        if gradient then
            -- Both native tint and gradient color the vertices. Combine them before
            -- setting the gradient instead of letting one setter erase the other.
            local from, to = {}, {}
            for index = 1, 4 do
                local channel = tint and tint[index] or 1
                from[index] = gradient.fromColor[index] * channel
                to[index] = gradient.toColor[index] * channel
            end
            _G.Declarus.Client._ApplyGradient(texture, gradient.orientation, from, to)
        elseif tint then
            texture:SetVertexColor(tint[1], tint[2], tint[3], tint[4])
        end
    end
    if view.properties.opacity then frame:SetAlpha(view.properties.opacity) end
    if view.properties.visible == false then frame:Hide() end

    if view.kind == "ScrollView" then
        local padding = view.properties.padding or {}
        local viewport = CreateFrame("ScrollFrame", nil, frame)
        local width = math.max(0, arranged.width - (padding.left or 0) - (padding.right or 0))
        local height = math.max(0, arranged.height - (padding.top or 0) - (padding.bottom or 0))
        viewport:SetSize(width, height)
        viewport:SetPoint("TOPLEFT", frame, "TOPLEFT", padding.left or 0, -(padding.top or 0))
        local childSize = arranged.children[1]
        local content = RenderView(view.children[1], childSize, viewport, childSize)
        viewport:SetScrollChild(content)
        viewport:EnableMouseWheel(true)
        viewport:SetScript("OnMouseWheel", function(self, delta)
            local maximum = math.max(0, childSize.height - height)
            self:SetVerticalScroll(math.max(0, math.min(maximum, self:GetVerticalScroll() - delta * 30)))
        end)
        return frame
    end

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