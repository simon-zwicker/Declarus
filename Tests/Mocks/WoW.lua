
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Mocks/WoW
-- Description: Provides a minimal World of Warcraft API mock for testing
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines mock frames and textures
-- ============================================================================

---@class DeclarusMockTexture
---@field color number[]?
---@field allPoints Frame?
---@field SetAllPoints fun(self: DeclarusMockTexture, frame: Frame)
---@field SetColorTexture fun(self: DeclarusMockTexture, r: number, g: number, b: number, a?: number)

---@class DeclarusMockFrame
---@field parent Frame?
---@field width number
---@field height number
---@field points table[]
---@field children DeclarusMockFrame[]
---@field textures DeclarusMockTexture[]
---@field SetSize fun(self: DeclarusMockFrame, width: number, height: number)
---@field SetPoint fun(self: DeclarusMockFrame, point: string, relativeTo: Frame, relativePoint: string, x: number, y: number)
---@field CreateTexture fun(self: DeclarusMockFrame, name?: string, layer?: string): DeclarusMockTexture

-- ============================================================================
-- Title:       Locals
-- Description: Defines mock prototypes
-- ============================================================================

local FrameMock = {}
FrameMock.__index = FrameMock

local TextureMock = {}
TextureMock.__index = TextureMock

-- ============================================================================
-- Title:       Texture Implementation
-- Description: Simulates WoW texture methods
-- ============================================================================

function TextureMock:SetAllPoints(frame)
    self.allPoints = frame
end

function TextureMock:SetColorTexture(r, g, b, a)
    self.color = { r, g, b, a or 1 }
end

-- ============================================================================
-- Title:       Frame Implementation
-- Description: Simulates WoW frame methods
-- ============================================================================

function FrameMock:SetSize(width, height)
    self.width = width
    self.height = height
end

function FrameMock:SetPoint(point, relativeTo, relativePoint, x, y)
    table.insert(self.points, {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
    })
end

function FrameMock:CreateTexture(name, layer)
    local texture = setmetatable({
        name = name,
        layer = layer,
    }, TextureMock)

    table.insert(self.textures, texture)

    return texture
end

function FrameMock:GetObjectType()
    return self.frameType
end

-- ============================================================================
-- Title:       WoW API
-- Description: Simulates CreateFrame and UIParent
-- ============================================================================

---@param frameType string
---@param name? string
---@param parent? Frame
---@return Frame
function CreateFrame(frameType, name, parent)
    ---@type DeclarusMockFrame
    local frame = setmetatable({
        frameType = frameType,
        name = name,
        parent = parent,
        width = 0,
        height = 0,
        points = {},
        textures = {},
        children = {},
    }, FrameMock)

    -- Register the frame as a child of its parent.
    if parent then
        ---@cast parent DeclarusMockFrame
        table.insert(parent.children, frame)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return frame
end

UIParent = CreateFrame("Frame", "UIParent")