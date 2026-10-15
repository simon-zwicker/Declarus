
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Engine/LocalizationResolver
-- Description: Resolves localized text for declarative views
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- ============================================================================

local UI = _G.Declarus.UI

---@class DeclarusLocalizationResolver
local LocalizationResolver = {}

-- ============================================================================
-- Title:       Resolution
-- ============================================================================

---Resolves a string using the provided localization instance.
---@param value string
---@param localization? DeclarusLocalization
---@return string
function LocalizationResolver.Resolve(value, localization)
    if not localization then
        return value
    end

    return localization:Get(value)
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

UI._LocalizationResolver = LocalizationResolver