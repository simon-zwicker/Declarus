
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

---@class DeclarusMockTexture: Texture
---@field layer? string
---@field color number[]?
---@field allPoints Frame?
---@field SetAllPoints fun(self: DeclarusMockTexture, frame: Frame)
---@field SetColorTexture fun(self: DeclarusMockTexture, r: number, g: number, b: number, a?: number)

---@class DeclarusMockFrame: Frame, Button, EditBox, Slider, CheckButton, ScrollFrame
---@field parent? DeclarusMockFrame
---@field frameType string
---@field hidden? boolean
---@field alpha? number
---@field autoFocus? boolean
---@field value? number
---@field scripts table<string, function>
---@field scroll? number
---@field scrollChild? DeclarusMockFrame
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

---@class DeclarusMockFontString: FontString
---@field text string
---@field font string
---@field fontSize number
---@field point? table
---@field SetPoint fun(self: DeclarusMockFontString, point: string, relativeTo: Frame, relativePoint: string, x: number, y: number)
---@field SetFont fun(self: DeclarusMockFontString, font: string, size: number, flags?: string)
---@field SetText fun(self: DeclarusMockFontString, text: string)
---@field GetStringWidth fun(self: DeclarusMockFontString): number
---@field GetStringHeight fun(self: DeclarusMockFontString): number

-- ============================================================================
-- Title:       Locals
-- Description: Defines mock prototypes
-- ============================================================================

---@class DeclarusMockFrame
local FrameMock = {}
FrameMock.__index = FrameMock

---@class DeclarusMockTexture
local TextureMock = {}
TextureMock.__index = TextureMock

---@class DeclarusMockFontString
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
---@return DeclarusMockFrame
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

function FrameMock:SetScript(event, callback)
    self.scripts = self.scripts or {}
    self.scripts[event] = callback
end
function FrameMock:RegisterForClicks(...) self.clicks = {...} end
function FrameMock:SetAutoFocus(value) self.autoFocus = value end
function FrameMock:SetMultiLine(value) self.multiLine = value end
function FrameMock:SetFont(...) self.font = {...} end
function FrameMock:SetTextInsets(...) self.insets = {...} end
function FrameMock:SetText(value) self.text = value end
function FrameMock:GetText() return self.text end
function FrameMock:ClearFocus() self.focus = false end
function FrameMock:SetOrientation(value) self.orientation = value end
function FrameMock:SetMinMaxValues(a, b) self.minimum, self.maximum = a, b end
function FrameMock:SetValueStep(value) self.step = value end
function FrameMock:SetThumbTexture(value) self.thumb = value end
function FrameMock:SetValue(value)
    self.value = value
    if self.scripts and self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end
end
function FrameMock:SetChecked(value) self.checked = value end
function FrameMock:GetChecked() return self.checked end
function FrameMock:SetNormalTexture(value) self.normal = value end
function FrameMock:SetCheckedTexture(value) self.checkedTexture = value end
function FrameMock:SetFrameStrata(value) self.strata = value end
function FrameMock:IsShown() return not self.hidden end

function FrameMock:GetChildren() return unpack(self.children) end
function FrameMock:HasScript(event) return self.scripts and self.scripts[event] ~= nil end
function FrameMock:UnregisterAllEvents() self.events = {} end
function FrameMock:SetParent(parent)
    ---@cast parent DeclarusMockFrame?
    if self.parent then
        for i, child in ipairs(self.parent.children) do
            if child == self then table.remove(self.parent.children, i); break end
        end
    end
    self.parent = parent
    if parent then table.insert(parent.children, self) end
end
function FrameMock:SetScrollChild(child)
    ---@cast child DeclarusMockFrame
    self.scrollChild = child
end
function FrameMock:EnableMouseWheel(value) self.mouseWheel = value end
function FrameMock:GetVerticalScroll() return self.scroll or 0 end
function FrameMock:SetVerticalScroll(value) self.scroll = value end
