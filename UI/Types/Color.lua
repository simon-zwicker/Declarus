
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Types/Color
-- Description: Provides color utilities for DeclarusUI elements
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines color types, tokens and factory methods
-- ============================================================================

---@alias DeclarusColor number[]

---@class DeclarusColorFactory
---@field RGB fun(red: number, green: number, blue: number): DeclarusColor
---@field RGBA fun(red: number, green: number, blue: number, alpha: number): DeclarusColor

-- ============================================================================
-- Title:       Locals
-- Description: Defines local dependencies and the color factory
-- ============================================================================

local UI = _G.Declarus.UI
local Color = {}

-- ============================================================================
-- Title:       Implementation
-- Description: Creates normalized RGBA color values
-- ============================================================================

---Creates an RGBA color with normalized RGB values
---@param red number
---@param green number
---@param blue number
---@param alpha number
---@return DeclarusColor
function Color.RGBA(red, green, blue, alpha)
    return {
        red / 255,
        green / 255,
        blue / 255,
        alpha,
    }
end

---Creates an opaque RGB color
---@param red number
---@param green number
---@param blue number
---@return DeclarusColor
function Color.RGB(red, green, blue)
    return Color.RGBA(red, green, blue, 1)
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the color factory within DeclarusUI
-- ============================================================================

---@cast Color DeclarusColorFactory

UI.Color = Color
