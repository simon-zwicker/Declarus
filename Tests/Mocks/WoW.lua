
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

---@class DeclarusMockFrame: Frame
---@field parent Frame?
---@field width number
---@field height number
---@field points table[]
---@field children DeclarusMockFrame[]
---@field textures DeclarusMockTexture[]
---@field fontStrings DeclarusMockFontString[]
---@field CreateFontString fun(self: DeclarusMockFrame, name?: string, layer?: string): DeclarusMockFontString
---@field SetSize fun(self: DeclarusMockFrame, width: number, height: number)
---@field SetPoint fun(self: DeclarusMockFrame, point: string, relativeTo: Frame, relativePoint: string, x: number, y: number)
---@field CreateTexture fun(self: DeclarusMockFrame, name?: string, layer?: string): DeclarusMockTexture

---@class DeclarusMockFontString
---@field text string
---@field font string
---@field fontSize number
---@field point? table
---@field SetPoint fun(self: DeclarusMockFontString, point: string, relativeTo: Frame, relativePoint: string, x: number, y: number)
---@field SetFont fun(self: DeclarusMockFontString, font: string, size: number)
---@field SetText fun(self: DeclarusMockFontString, text: string)
---@field GetStringWidth fun(self: DeclarusMockFontString): number
---@field GetStringHeight fun(self: DeclarusMockFontString): number

-- ============================================================================
-- Title:       Locals
-- Description: Defines mock prototypes
-- ============================================================================

local FrameMock = {}
FrameMock.__index = FrameMock

local TextureMock = {}
TextureMock.__index = TextureMock

local FontStringMock = {}
FontStringMock.__index = FontStringMock

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

function FrameMock:CreateFontString(name, layer)
    local fontString = setmetatable({
        name = name,
        layer = layer,
        text = "",
        font = "",
        fontSize = 12,
    }, FontStringMock)

    table.insert(self.fontStrings, fontString)

    return fontString
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
        fontStrings = {}, -- NEU
        children = {},
    }, FrameMock)

    if parent then
        ---@cast parent DeclarusMockFrame
        table.insert(parent.children, frame)
    end

    return frame
end

-- ============================================================================
-- Title:       Localization
-- Description: Mocks the World of Warcraft locale API
-- ============================================================================

local activeLocale = "enUS"

---Returns the currently active mock locale.
---@return string
function GetLocale()
    return activeLocale
end

---Sets the active locale for testing.
---@param locale string
function SetMockLocale(locale)
    activeLocale = locale
end

-- ============================================================================
-- Title:       FontString Implementation
-- Description: Simulates WoW FontString methods
-- ============================================================================

function FontStringMock:SetFont(font, size, flags)
    self.flags = flags
    self.font = font
    self.fontSize = size
end

function FontStringMock:SetText(text)
    self.text = text
end

function FontStringMock:GetStringWidth()
    return #self.text * self.fontSize * 0.5
end

function FontStringMock:GetStringHeight()
    return self.fontSize
end

function FontStringMock:SetPoint(point, relativeTo, relativePoint, x, y)
    self.point = {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

UIParent = CreateFrame("Frame", "UIParent")
function TextureMock:SetTexture(source) self.source = source end
function FrameMock:SetAlpha(alpha) self.alpha = alpha end
function FrameMock:Hide() self.hidden = true end
function FrameMock:Show() self.hidden = false end
function FontStringMock:SetTextColor(...) self.color = {...} end
