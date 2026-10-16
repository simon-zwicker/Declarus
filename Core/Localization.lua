
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Core/Localization
-- Description: Provides namespaced localization with locale fallback
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- ============================================================================

---@class DeclarusLocalization
---@field namespace string
---@field translations table<string, table<string, string>>

---@class DeclarusLocalizationManager

-- ============================================================================
-- Title:       Locals
-- ============================================================================

local Declarus = _G.Declarus

---@class DeclarusLocalizationManager
local Localization = {}

local DEFAULT_LOCALE = "enUS"

---@type table<string, DeclarusLocalization>
local instances = {}

-- ============================================================================
-- Title:       Locale
-- ============================================================================

---Returns the active WoW client locale.
---@return string
function Localization.GetActiveLocale()
    return GetLocale() or DEFAULT_LOCALE
end

-- ============================================================================
-- Title:       Localization
-- ============================================================================

---Creates or retrieves a namespaced localization instance.
---@param namespace string
---@return DeclarusLocalization
function Localization.Create(namespace)
    assert(
        type(namespace) == "string" and namespace ~= "",
        "Localization requires a namespace"
    )

    if instances[namespace] then
        return instances[namespace]
    end

    ---@class DeclarusLocalization
    local instance = {
        namespace = namespace,
        translations = {},
    }

    ---Registers translations for a locale.
    ---@param locale string
    ---@param translations table<string, string>
    function instance:Register(locale, translations)
        assert(
            type(locale) == "string" and locale ~= "",
            "Localization requires a locale"
        )

        assert(
            type(translations) == "table",
            "Localization requires a translations table"
        )

        local registered = self.translations[locale]

        if not registered then
            registered = {}
            self.translations[locale] = registered
        end

        for key, value in pairs(translations) do
            registered[key] = value
        end
    end

    ---Resolves a localization key.
    ---Falls back to enUS, then to the original key.
    ---@param key string
    ---@return string
    function instance:Get(key)
        local locale = Localization.GetActiveLocale()

        local active = self.translations[locale]
        local fallback = self.translations[DEFAULT_LOCALE]

        if active and active[key] then
            return active[key]
        end

        if fallback and fallback[key] then
            return fallback[key]
        end

        return key
    end

    instances[namespace] = instance

    return instance
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

Declarus.Localization = Localization