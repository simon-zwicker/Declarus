
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Typography/TextMeasure
-- Description: Measures text using World of Warcraft FontStrings
-- ============================================================================

local UI = _G.Declarus.UI

local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
local DEFAULT_FONT_SIZE = 16

---@class DeclarusTextMeasure
local TextMeasure = {}

-- Reuse one FontString for measurements.
local measurementFrame = CreateFrame("Frame", nil, UIParent)
local measurementText = measurementFrame:CreateFontString(nil, "ARTWORK")

---Measures the intrinsic size of a text view.
---@param view DeclarusTextView
---@return DeclarusSize2D
function TextMeasure.Measure(view)
    local properties = view.properties

    local text = UI._LocalizationResolver.Resolve(
        properties.text or "",
        properties.localization
    )

    measurementText:SetFont(
        DEFAULT_FONT,
        DEFAULT_FONT_SIZE
    )

    measurementText:SetText(text)

    return {
        width = measurementText:GetStringWidth(),
        height = measurementText:GetStringHeight(),
    }
end

UI._TextMeasure = TextMeasure